---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: Wordpress on OpenShift 2
date: 2017-08-10 17:14:30.000000000 +00:00
categories: jyeary
tags: web
subclass: 'post tag-web'
---
This is my attempt to get Wordpress running on OpenShift 2 using 2 gears. I would like to migrate my personal blog for John Yeary from Blogger to another blogging platform so that I have more control of the
layout, and appearance. So I backed up the data from Blogger and used the import tool and it seems to have worked more amazingly than I could have imagined. 

Connecting to the MySQL database on the gear requires a little more finesse since it is not exposed publicly. Great for security, but not so great for getting remote access. I used the `rhc
port-forward` command to accomplish the task.

    rhc port-forward -a <application-name>

Here are the items that I see remaining:

  - ~~Perform the same operations on a test blog, and see if blogger
    will forward requests correctly.~~
  - ~~Check permlinks to ensure that they still work.~~
  - ~~Setup SSL.~~
  - ~~Move media from the gear to cloud storage.~~
  - ~~Backup and restore database.~~
  - ~~Install Wordpress on another platform and use a newer version of
    MySQL to see if there are any issues.~~
  - ~~Add Google Adsense to see if they work.~~
  - ~~Test Amazon Associate links.~~
  - ~~Update Amazon Associates links.~~
  - ~~Add SSO Login API for Disqus~~
  - ~~Fix broken links on posts.~~

So far it has worked. The blog is running on a 2 gears with a load balancer. I have migrated the blog. I still need to Adsense, and update Amazon Associates links.