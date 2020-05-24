---
layout: post
cover: 'assets/images/abstract-apple-art-black-and-white-434346.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2009-12-14 17:15:00+00:00
title: Translating Line Feeds for Mac OS X, UNIX, and Windows
categories: jyeary
tags: mac
subclass: 'post tag-mac'
---
I have been asked to show how to translate line feeds between Mac, UNIX, and Windows. This comes up often so here is one way using PERL which was designed to do just what we need.  
1. How to translate Mac OS file linefeed to UNIX linefeeds:  
  ```
  perl -pi -e 's/r/n/g' file_with_mac_linefeeds.txt
  ``` 
2. How to translate UNIX file linefeeds to Mac OS linefeeds:  
  ```
  perl -pi -e 's/n/r/g' file_with_unix_linefeeds.txt
  ```
3. Translate a Windows file linefeeds to UNIX linefeeds:  
  ```
  perl -pi -e 's/rn/n/g' file_with_win_linefeeds.txt
  ```
4. Translate Windows file linefeeds to Mac OS linefeeds:  
  ```
  perl -pi -e 's/rn/r/g' file_with_win_linefeeds.txt
  ```  

I hope this is a real time saver. Let me know!
