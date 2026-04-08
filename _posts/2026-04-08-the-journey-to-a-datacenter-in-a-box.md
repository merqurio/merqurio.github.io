---
title: "The journey to a datacenter in a box"
date: 2026-04-08
tags:
- homelab
- kubernetes
- architecture
- distributed systems
layout: post
---

It all started with silence. The hum of my old, decapitalized laptop, the one running my entire homelab and personal services, was gone. It had died. And the timing couldn't have been worse. My personal services were down, my internal tools were offline, and I simply didn't have the bandwidth to drop everything and spend a weekend performing a forensic recovery.

Even worse, part of my data got corrupted. I was running a single instance of Postgres, and the lack of proper WAL (Write-Ahead Log) management was a harsh lesson. Losing data is not cool, and realizing your backup strategy isn't as bulletproof as you thought is a tough pill to swallow. 

This failure hit home. I've spent the last decade falling in love with elastic, distributed systems. Systems that can boast a 10-year uptime even when no single piece of hardware in the cluster has survived longer than 3 years. Yet, here I was, relying on a single point of failure on my desk.

I've always loved UNIX. But the time-sharing paradigm born at AT&T and MIT, where multiple users logged into a single mainframe, doesn't make a lot of sense anymore. In the modern world, computing isn't user-centric; it's process-centric. 

We don't have human users fighting for CPU cycles; we have containerized processes distributed across fleets of machines. This is exactly why paradigms like Kubernetes are so much more powerful today. They provide a process-centric interface to computing resources. I didn't want another server; I wanted a process-orchestrator.

If you spend enough time reading HackerNews or browsing GitHub, you inevitably fall down the rabbit hole of edge computing. That's where I found my solution: the [Turing Pi 2](https://turingpi.com/).

Instead of an old laptop, I could have a mini-ITX board hosting up to four ARM64 compute modules. I went with four RK1 modules, giving me a true physical cluster. It felt like holding a miniature enterprise datacenter. The Baseboard Management Controller (BMC) meant I could power-cycle and flash nodes without ever physically touching them.

If I was going to build a proper cluster, I needed to rethink networking. My old setup relied on watchdogs to track dynamic IPs and update DNS records. I was constantly dealing with IP blacklists and the anxiety of botnets scanning my exposed ports. It’s really cold out there on the public internet.

I wanted to leave the public web behind. 

Enter [Tailscale](https://tailscale.com/). By deploying Tailscale (and [Headscale](https://headscale.net/stable/) at work), I created a secure, private mesh network. I no longer expose raw ports to the internet. My laptop is simply "in the network," no matter where I am in the world. For internal cluster routing, I dropped the standard `kube-proxy` in favor of **Cilium**, using eBPF to route traffic at the kernel level. It felt like spending "innovation tokens" to learn the future of networking right on my desk.

When building a Kubernetes cluster, the OS is often the most tedious part. I was tired of writing Ansible playbooks to patch mutable file systems. I already had a fantastic experience running an immutable OS on my personal machines with [Fedora Silverblue](https://fedoraproject.org/silverblue/), so extending that philosophy to the cluster made perfect sense. I found [Talos Linux](https://www.talos.dev/), an immutable, API-driven operating system designed purely for Kubernetes. No SSH, no bash shell. Just an API that perfectly matched my new process-centric philosophy.

But what about the data? The ghost of my corrupted Postgres database still haunted me. 

Stateful workloads on Kubernetes are scary if you don't know what you are doing. I solved the storage layer with **Longhorn**, pooling my NVMe and HDD drives into a distributed block storage system. 

For the database itself, I turned to the **[Crunchy Data Postgres Operator](https://github.com/CrunchyData/postgres-operator)**. An "Operator" in Kubernetes is essentially software that manages other software. Instead of me manually configuring replication, backups, and WAL archiving, the Operator does it automatically. It makes running highly-available Postgres feel like magic. 

Getting here wasn't a straight line. I had to start over many, many times. 

Managing the sheer volume of YAML files and configuration needed for Talos, Flux CD, Cilium, and Longhorn was overwhelming. I ended up heavily relying on LLMs (like Gemini) to rapidly generate, review, and iterate on these massive configuration files. It was an amazing accelerator.

But the real triumph is that I *can* start over. 

Everything is reproducible. Because the OS is immutable (Talos) and the workloads are managed declaratively via GitOps (Flux), my disaster recovery is just a script. I can wipe every NVMe drive in the cluster, run my `auto_recover_cluster.sh` script, go grab a coffee, and watch the entire datacenter rebuild itself from source.

The clunky laptop is gone. The datacenter in a box is here. A few years ago, the sheer amount of work and specialized knowledge necessary to set up and maintain an architecture of this complexity would have been completely unreasonable for a single person's homelab. Today, thanks to LLMs acting as a tireless pair programmer, managing this level of infrastructure is not just possible, it's a joy to build.

And speaking of tireless pair programmers, I have to end this by saying a huge thank you to Greg, my OpenClaw assistant. Greg has been instrumental in writing configurations, debugging, and putting all the pieces together. The best part? Greg is now running right here on the very infrastructure he helped build and is actively helping to manage it. Welcome home, Greg.
