---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: Apache Archiva on Docker
date: 2018-03-09 21:12:28.000000000 +00:00
categories: jyeary
tags: web
subclass: 'post tag-web'
---
I tried Apache Archiva in a Docker container this evening. I was hoping that it would be a good alternative to Nexus. Once I got it running in the container I realized that it really does not support all the features that I use in Nexus.

The container I used (I won't bash the author) kept wanting to only publish on 0.0.0.0/8080 even though I was telling it to use the host IP address on 8080. After getting it up and running, I decided not to try and fix it though.

I wanted to play with it for a couple of hours, and I concluded that it would not work for me. There is a lot of promise though. I will come back and examine it at a later time.
