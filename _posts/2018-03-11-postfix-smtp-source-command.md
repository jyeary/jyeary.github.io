---
layout: post
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-03-11 17:47:09+00:00
title: Postfix smtp-source command
categories: jyeary
tags: java unix
subclass: 'post tag-java tag-unix'
---
I was looking at some ideas for re-implementing an SMTP server that I work on for my day job. As I was reading about a [netty](https://netty.io/index.html) example implementation called [smptd](https://github.com/brightcode/smtpd) on github. I saw something very interesting. He was testing his code using a command from [Postfix](http://www.postfix.org) called [smtp-source](http://www.postfix.org/smtp-source.1.html). I was immediately interested. I pulled his example code and updated it for a newer version of netty (3.10.6) and started it up. I then pulled an [Ubuntu](https://hub.docker.com/_/ubuntu/) image from [Docker Hub](https://hub.docker.com) and started it up. Once it was started, I used apt-get to install Postfix. The result was that I had my own little test environment up in about 5 minutes. So I tested the code from the smtpd project on my Windows 10 Pro machine ([HP Pavillion Wave](http://www8.hp.com/us/en/campaigns/pavilion-wave/overview.html) for those who are interested) using the smtp-source command from a Docker container. Here were my results.

```
time smtp-source -c -d -l 32000 -m 10000 -N -s 100 10.0.1.9:2525
```

```
real 0m12.543s
user 0m0.410s
sys 0m2.640s
```

The results were very interesting on a non-server class machine, or environment. It handled 10,000 email requests with 100 simultaneous connections in 12 seconds. I was impressed. `time` is a built in function on UNIX machines. The **real** time is the time that was used to process the requests. This was just a really good demonstration of Docker, containers, Postfix tools, and netty.