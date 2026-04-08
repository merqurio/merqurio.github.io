---
layout: post
title: Datacenter in a Box
subtitle: "A deep dive into Talos Linux, Kubernetes, and self-hosting my entire business stack on four RK1 compute modules."
date: 2026-04-09 00:00:00 Z
author: "Gabriel Maeztu"
tags: ["homelab", "kubernetes", "talos", "arm64", "self-hosting"]
---

For the longest time, I ran my homelab workloads on an old clunky decapitalized laptop. While it got the job done, I was missing out on the resilience, density, and low power consumption I wanted for my family's digital home. I also wanted to explore the next generation of  infrastructure, before adopting it at work. Inmmutable systems that run close to the metal, a cluster in a way that felt like operating a real datacenter, but scaled down to sit quietly on my desk.

This is the story of how I built a 4-node, highly available Kubernetes cluster on the [Turing Pi 2](https://turingpi.com/) using [Talos Linux](https://www.talos.dev/), and how I use it to self-host **[evidify](https://evidify.it)**, automation platforms, and full observability stack.


#### Accessing the Cluster

Before diving into the hardware and Kubernetes layers, I have to mention the magic of **[Tailscale](https://tailscale.com/)**. For those unfamiliar, Tailscale is a zero-config VPN built on top of [WireGuard](https://www.wireguard.com/) that creates a secure, peer-to-peer mesh network between your devices. Running a homelab is great, but accessing it securely can be a headache. I've been down the route of ever updating the DNS config to point to my home IP and expose some ports... and I wanted to bring the same seamless experience we have at work.

Thanks to installing Tailscale in my network (in a small dedicated SBC), it has been the perfect door to access the cluster remotely from my laptop. It gives me the feeling of being always in the local network, no matter where I am in the world. I can seamlessly interact with the Kubernetes API, access internal dashboards, and manage the nodes without exposing any raw ports to the public internet.

While Tailscale's hosted control plane is perfect for my homelab, at work we use **[Headscale](https://headscale.net/stable/)**, the open-source, self-hosted implementation of the Tailscale control server. This gives us the exact same developer experience but with complete data sovereignty and control over our corporate network routing. For my homelab, I'm more than happy to rely on Tailscale itself.

### Hardware

At the heart of the hardware setup is the **Turing Pi 2**, a mini-ITX cluster board that lets you plug in up to 4 compute modules. Instead of Raspberry Pis, I opted for four **RK1 Compute Modules**. These are powerful ARM64 boards that support NVMe storage directly, providing good I/O performance for database workloads.

| Component | Product |
| :--- | :--- |
| **Board** | [Turing Pi 2](https://turingpi.com/product/turing-pi-2/) Baseboard Management Controller (BMC) |
| **Compute Nodes** | 4x 32Gb [Turing RK1 (ARM64)](https://turingpi.com/product/turing-rk1/) |
| **Storage (NVMe)** | 4x 100GB NVMe SSDs |
| **Storage (HDD)** | 8x 500GB SATA HDDs |

The BMC is a game-changer. It allows me to remotely power-cycle nodes, access serial consoles, and re-flash the OS without ever touching the physical hardware. For instance, connecting to the serial consoles using `picocom /dev/ttyS{1,4} -b 115200` from the BMC makes debugging Talos incredibly easy, especially when network access isn't available yet.


### Avoiding the operating system

When building a Kubernetes cluster, the underlying OS is often the most tedious step. Traditional distributions require patching, SSH access, and configuration management. I'm tired of [ansible](https://github.com/ansible/ansible) or [puppet](https://github.com/puppetlabs/puppet) scripts, and after having an [immutable fedora](https://fedoraproject.org/silverblue/) in my old laptop, I wanteed to double down on that path. 

[Talos](https://docs.siderolabs.com/talos/v1.12/overview/what-is-talos) is an *immutable*, API-driven operating system designed specifically for Kubernetes. There is no SSH, no bash shell, and no mutable file system. You interact with the OS purely through an API using the `talosctl` command-line tool from your laptop. Build the image, bootstrap the node and 🚀, you have a k8s node up and running.

#### Generating and Flashing the Image

Because the RK1 is an ARM64 board with specific hardware requirements, you don't use a generic ISO. Instead, you use the [Talos Factory](https://factory.talos.dev/), an online tool that lets you bake custom OS images with the exact kernel arguments and system extensions your hardware needs.

1. **Generate:** Go to the Talos Factory, select the **Turing RK1** board profile, choose your target Talos version, and download the generated raw metal image.
2. **Flash:** Thanks to the Turing Pi 2's BMC, you don't need to physically remove the compute modules to flash them. I downloaded the generated metal image (`metal-arm64.raw`) directly onto the BMC's SD card. From there, I can use the `tpi` command-line tool via SSH to flash the nodes directly.

For example, to flash Node 1:

```bash
# SSH into the BMC
ssh root@<bmc-ip>

# Flash the image directly to Node 1's NVMe drive
tpi flash --image-path "/mnt/sdcard/metal-arm64.raw" --node 1
```


#### The management layer

My configuration is entirely declarative.

k8s is the orchestrator that ensures my apps stay running, load-balances traffic, and automatically restarts failed containers. But managing Kubernetes manifests manually is a recipe for disaster.

To solve this, I use **GitOps** via [Flux CD](https://fluxcd.io/). My entire infrastructure is stored in a Git repository. Flux constantly watches the `main` branch and automatically applies any changes to the cluster. If someone (or something) manually deletes a deployment, Flux restores it to match the state in Git.


#### Networking: Cilium, Tailscale & Cloudflared

Instead of relying on standard `kube-proxy` and `iptables` for routing traffic between pods, I use **Cilium**. Cilium leverages **eBPF** (Extended Berkeley Packet Filter), a technology that allows you to run sandboxed programs directly within the Linux kernel. Another moment to try another new way of doing things. Although I wouldn't use so many [innovation tokens](https://boringtechnology.club/) at work, a homelab is for me an great environment to keep up with the latest advancements in the community.

Beyond internal cluster routing, having a Kubernetes instance combined with **Cilium** and **[Cloudflared](https://github.com/cloudflare/cloudflared)** tunnels is a superpower. It allows me to easily expose the different services exactly how I want: Cloudflared tunnels handle secure, public-facing internet traffic send to the Cilium Ingress Controller, while [Tailscale Ingress](https://tailscale.com/docs/kubernetes#use-the-kubernetes-operator) handles routing to my private intranet services that should never touch the public web.

#### Storage: Longhorn

For storage, I use **Longhorn**. It aggregates the individual drives attached to my RK1 nodes into a highly available, distributed block storage pool. If Node 1 crashes, the data for my applications is accessible from Node 2 or Node 3 because Longhorn maintains synchronous replicas across the cluster.

To manage the different performance profiles of the drives, I heavily utilize Longhorn's **disk tagging** features to create distinct storage tiers:

- **Performance Tier (NVMe / SSD):** Each of the 4 nodes has a dedicated ~128GB NVMe drive (tagged `nvme` and `ssd`). This tier is reserved for workloads that require high IOPS, like databases or active application caches.
- **Bulk Tier (SATA / HDD):** I have a total of eight 500GB SATA HDDs distributed across the cluster (3 on node 1, 3 on node 2, and 2 on node 3), yielding roughly 4TB of raw capacity. These drives are tagged `hdd` and `sata` and are perfect for high-capacity, lower-throughput workloads like backups, logs, and media storage.

By applying node and disk tags within Longhorn, I can instruct Kubernetes StorageClasses to automatically place volumes on either the fast NVMe tier or the bulk HDD tier depending on the application's needs.


### The Data Layer

Running databases in Kubernetes can be terrifying if not done correctly. I rely on the **[Crunchy Data Postgres Operator (PGO)](https://github.com/CrunchyData/postgres-operator)** to manage my PostgreSQL instances. Feels like home. An extremely k8s native, declarative way of managing databases.

My standard deployment pattern includes:
- **3 Replicas** with Pod Anti-Affinity (ensuring no two database pods run on the same physical node).
- **Dual-repo backups**: Local snapshots to Longhorn, and off-site (GCS) encrypted backups.

For local object storage, I run **[Garage](https://garagehq.deuxfleurs.fr/documentation/quick-start/)**, a lightweight, S3-compatible distributed storage system tailored for self-hosting. My Postgres operator pushes its WAL (Write-Ahead Logs) directly to Garage S3 buckets.


### The Workloads

The primary reason this cluster exists is to host my personal and business operations securely, with full sovereignty.

- **Evidify:** A heavily customized Quality Magamente System. I run multiple isolated instances of Evidify (`dev`, `test`, `demo`, `prod`) simultaneously using Kustomize overlays.


### Observability: The LGTM Stack

If a cluster falls in a forest, does it make a log? To keep an eye on everything, I run the **LGTM stack**, again, feels like home:
- **Loki** aggregates logs from every pod and node, storing them cheaply in my Garage S3 buckets.
- **Prometheus** scrapes metrics like CPU usage, memory consumption, and network throughput.
- **Grafana** visualizes the data.


### Disaster Recovery

In the infrastructure world, we treat servers like "cattle, not pets." If a server is sick, you don't nurse it back to health—you replace it.

Because my entire setup is code (GitOps) and API-driven (Talos), disaster recovery is completely automated. I wrote a script (`auto_recover_cluster.sh`) that uses `expect` and `picocom` to connect to the Turing Pi 2's BMC via SSH.

In the event of a total cluster failure, this script can:
1. Boot the nodes into Maintenance Mode from a raw image stored on the BMC's SD card.
2. Wipe the NVMe drives.
3. Apply the Talos OS machine configs.
4. Bootstrap the new Kubernetes control plane.
5. Re-install Flux CD, which then pulls down the entire cluster state from Git.

Within minutes, the cluster rebuilds itself from scratch without any manual intervention.

### Next Steps

Right now, the cluster is rock-solid. Moving forward, I plan to:
- Explore running local AI/LLM workloads utilizing the NPU (Neural Processing Unit) available on the RK1 chips.
- Optimize the ARM64 container builds for Evidify to reduce image sizes and startup times.
- Implement more granular Cilium Network Policies to completely isolate the `dev` and `prod` namespaces from one another at the kernel level.

Building a datacenter-in-a-box has been an incredible learning experience, and the Turing Pi 2 combined with Talos Linux is a match made in heaven for edge computing and self-hosting!
