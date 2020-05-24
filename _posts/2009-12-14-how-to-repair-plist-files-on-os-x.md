---
layout: post
cover: 'assets/images/abstract-apple-art-black-and-white-434346.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: no
date: 2009-12-14 17:17:00+00:00
title: How to Repair plist files on OS X
categories: jyeary
tags: mac
subclass: 'post tag-mac'
---
To repair Preferences (.plist) files use the following command:

### User Preferences  
```
sudo plutil –s ~/Library/Preferences/*.plist
```

### System Preferences  
```
sudo plutil –s /Library/Preferences/*.plist
```
