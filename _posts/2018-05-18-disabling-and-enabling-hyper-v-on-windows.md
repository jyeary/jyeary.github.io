---
layout: post
cover: 'assets/images/brown-landscape-under-grey-sky-3244513.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-05-18 03:20:22+00:00
title: Disabling and Enabling Hyper-V on Windows
categories: jyeary
tags: life
subclass: 'post tag-life'
---
I needed to be able to run VMWare and VirtualBox from my Windows 10 Pro machine. This machine also has Docker on it. The issue is that you can only have one Hypervisor working at a time. So Docker **OR** VirtualBox and VMWare. A temporary solution is to disable the Hyper-V using the following commands. Once this disabled, you can run VirtualBox and VMWare.

### Disable
```
bcdedit /set hypervisorlaunchtype off
```
Reboot machine.

### Enable
```
bcdedit /set hypervisorlaunchtype auto
```
Reboot machine.

### Long Term Solution

A long-term solution using alternate boot commands is what I ended up using. The details can be found in this article: [Docker Tip #13: Get Docker for Windows and VirtualBox Working Together](https://nickjanetakis.com/blog/docker-tip-13-get-docker-for-windows-and-virtualbox-working-together).

This is for someone like me who switches more frequently than a casual user.