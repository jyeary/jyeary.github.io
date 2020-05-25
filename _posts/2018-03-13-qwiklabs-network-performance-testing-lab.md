---
layout: post
cover: 'assets/images/Wireshark_on_Xpra_Docker.png'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-03-13 20:03:54+00:00
title: Qwiklabs Network Performance Testing Lab
categories: jyeary
tags: web
subclass: 'post tag-web'
---
I completed the Qwiklabs Network Performance Testing Lab for Google Cloud Networking. In the lab, they mention using [Wireshark](https://www.wireshark.org/), or [CloudShark](https://www.cloudshark.org/) to examine the `webserver.pcap` file that is generated from the `tcpdump` command. They have you copy the file to a bucket and copy it from the bucket. 

This is not necessary. 

Once the file is copied to the cloud console, you can use the download option to download the file to your local machine from the cloud console. Once the file is on your local machine, you have options for viewing it. I personally didn't want to sign-up for CloudShark, and I didn't want to install Wireshark just to examine one file in a lab. I do use Wireshark on some machines at work, but installing it on my Mac, or Windows 10 Pro machine seemed like a waste of time and space. 

I decided to look on the Docker Hub and found a project [ffeldhaus/wireshark](https://hub.docker.com/r/ffeldhaus/wireshark/) that seemed to meet my needs. The other wireshark versions required X-Windows to be installed which would not work on a Windows 10 Pro platform. 

The ffeldhaus/wireshark version worked flawlessly. It uses [Xpra](https://xpra.org/) to expose Wireshark via a browser. It was slick. Once I copied the file to the wireshark container, it opened easily in the browser. The featured image in the blog is my actual data. `docker cp webserver.pcap wireshark:/` 

So when you are doing any of the labs, take a moment to consider other technologies and don't necessarily settle on the approach that the course is offering you.