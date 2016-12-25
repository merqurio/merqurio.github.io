---
title: Mount SD card in VirtualBox from Mac OS X Host
date: 2015-02-21 00:00:00 Z
layout: post
---

I love Linux. That said, my love to instability and research is too damn high to relay in a Linux Desktop as a work desktop (Yes, I know, that's my problem, not Linux). I just got a new Mac , so I wanted to get back my Linux installation without risking anything in my computer. This might seem crazy to some people, but I didn't want to install Linux in a second partition but in a thumb-drive. More exactly on a SD card. I know It would have some cons, but at least I wanted to try.

My very first temptation was doing it the old fashioned way, but I took the decision back in January that 2015 will be an exciting and adventurous year, so I decided to plug the SD card to Virtual-Box and make the installation there. So let's start!

### 1. Look for your drive

I'm using Mac right now, so let's check first where is my SD card located

`gabi@Book:[~]$ diskutil list` to check the disks:

{% highlight sh %}
/dev/disk0
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *251.0 GB   disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:          Apple_CoreStorage                         250.1 GB   disk0s2
   3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3

/dev/disk1
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:                  Apple_HFS book HD                *249.8 GB   disk1

/dev/disk2   <--- THIS ONE
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *32.0 GB    disk2
   1:                 DOS_FAT_32 UNTITLED                32.0 GB    disk2s1
{% endhighlight %}

Take note of the SD card device that shows up.  In my case, it was /dev/disk2. Let's unmount it so we can play with it.

```
gabi@Book:[~]$ diskutil unmountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
```

### 2. Create a pointer

Now, we need to create a Virtual-Box vmdk file that points to the SD card so that we can mount it as a device in a virtual machine. **Aha! the Magic Sauce.** You can save the file wherever you want. It's just a pointer.

```
gabi@Book:[~]$ sudo VBoxManage internalcommands createrawvmdk -filename /Users/gabi/VirtualBox\ VMs/sd-card.vmdk -rawdisk /dev/disk2
RAW host disk access VMDK file /Users/gabi/VirtualBox VMs/sd-card.vmdk created successfully.
```

Note, when we ran the mount command above, we did not include a portion. We want to create a pointer to the entire device (mine has 2 partitions).  So, just take the first portion of your device name and use it for the -rawdisk parameter.

Thus that we have a vmdk file pointing to the raw SD card device, we need to set permisisons on the vmdk file and the device. This might not be the nicest way BUT, It's what worked for me. This will ensure we are able to access and mount the vmdk file in VirtualBox.

```
gabi@Book:[~]$ sudo chmod 777 /dev/disk2
gabi@Book:[~]$ sudo chmod 777 /Users/gabi/VirtualBox\ VMs/sd-card.vmdk
```

### 3. Connecting the SD Card to Virtual-Box

Cool! time to make it available in Virtual-Box. First, let's create a new Machine. Do it thinking in your real machine. In my case an 64bit Arch Linux Box.

![64-bit Arch Linux Virtual-Box]({{ site.url }}/assets/img/posts/1.png)

We don't need a virtual HDD since we have already created one.

![We don't need a virtual HDD]({{ site.url }}/assets/img/posts/2.png)

Now unmount the disk again, because it's mounted automatically after the commands we have done.

`gabi@Book:[~]$ diskutil unmountDisk /dev/disk2`

Lets to add a SATA device in the virtual machine Storage configuration. Go under *Settings* > *Storage* and click “Add Hard Drive” on the SATA controller. “Choose existing disk”. Choose this option and then select the vmdk file you created earlier.

![add a SATA device]({{ site.url }}/assets/img/posts/3.png)

![choose the previously created pointer]({{ site.url }}/assets/img/posts/4.png)

Now, all we need to do is start your virtual machine with VirtualBox and your SD card should be accessible from the virtual machine. In my case I'll change some little setting to emulate an efi machine.
