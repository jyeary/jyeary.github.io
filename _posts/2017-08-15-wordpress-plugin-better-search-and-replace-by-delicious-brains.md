---
layout: post
cover: 'assets/images/pexels-photo-262488.jpeg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2017-08-15 02:28:36+00:00
title: 'WordPress Plugin: Better Search and Replace by Delicious Brains'
categories: jyeary
tags: web
subclass: 'post tag-web'
---
I want to take some time to point out some of the plugins that I have installed on my blog and used as part of migration from Blogger to WordPress. In my post [Online Broken Link Checker Tool for SEO](https://35.190.128.70/2017/08/online-broken-link-checker-tool-for-seo/) article, I mentioned how to track down broken links. Well once you have them, you can go to the pages and manually change them, or if possible you can change them en masse. This is particularly true if a site changes from something like **example.com/abc/test** to **example.com/test**. The links will work if you just remove the abc part of the URI. I encountered a lot of these for changes done at Informationweek and some of the other news media outlets. This is one of those cases where they didn't follow good practices with regards to permalinks.

The [Better Search and Replace](https://wordpress.org/plugins/better-search-replace/) plugin met my needs by allowing me to make changes to the saved posts by changing the URIs to match the new path to the resources. There is a pay version of the tool, but I didn't require it.

**A Word of Caution:** Before you take any action to alter your database, remember to back it up. This tool is directly manipulating data in your database. Also, make sure you perform a dry-run and examine the results.