---
layout: post
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2009-12-24 14:53:00+00:00
title: 'Tip: X-Window Display on localhost from Remote system (UNIX/Solaris/Linux/OS X)'
categories: jyeary
tags: mac unix
subclass: 'post tag-mac tag-unix'
---
X-Window display on local host with known hostname or IP address:
1. Confirm remote host has Xaccess configured to allow remote connections.
  **Note:**The file is located in /etc/dt/conf/ on Solaris 9 
2. Type on the local host:
  ```
  X -query <hostname or IP address>
  ```