---
layout: post
cover: 'assets/images/abstract-apple-art-black-and-white-434346.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2009-12-24 14:47:00+00:00
title: 'Tip: Resetting Enviroment Variables without Logging Out (UNIX/Solaris/Linux/OS X)'
categories: jyeary
tags: mac unix
subclass: 'post tag-mac tag-unix'
---
To reset environment variable changes in bash without logging out
```
source ~/.profile
```
Confirm changes by:
```
set | grep <changed parameter>
```
