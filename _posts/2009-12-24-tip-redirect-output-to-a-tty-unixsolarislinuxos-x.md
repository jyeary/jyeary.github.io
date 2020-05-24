---
layout: post
cover: 'assets/images/abstract-apple-art-black-and-white-434346.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2009-12-24 14:39:00+00:00
title: 'Tip: Redirect Output to a tty (UNIX/Solaris/Linux/OS X)'
categories: jyeary
tags: mac unix
subclass: 'post tag-mac tag-unix'
---
Redirect ouptut to tty using the following command:  
```
script -a /dev/null | tee /dev/pts/XXX
```
Where XXX is the `tty` target  
