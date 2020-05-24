---
layout: post
cover: 'assets/images/abstract-apple-art-black-and-white-434346.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: false
date: 2009-12-14 16:32:00+00:00
title: Loading /etc/hosts into NetInfo (OS X 10.4 Leopard)
categories: jyeary
tags: mac
subclass: 'post tag-mac'
---
You can load your **/etc/hosts** file into NetInfoManager's database using the following command:  
```
niload -m hosts < /etc/hosts
```