---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2020-05-26 20:34:34+00:00
title: Blog Migration Completed
categories: jyeary
tags: web
subclass: 'post tag-web'
---
I finally finished migrating my blog from Wordpress to GitHub pages over the Memorial Day weekend. I started the process when I was in Maine at the end of 2019. I now find myself almost six months into 2020 and finally completed the migration.

The significant advantage of Wordpress is its ease of use to get started. However, trying to maintain a database, and upgrades made it a chore. I was also hosting it on Google Cloud. That meant I was responsible for maintainence and security. I also had the additional expense of paying for the VM and data storage.

GitHub makes a compelling choice. This is particularly true since I write my pages in Markdown, and it is a first class citizen on GitHub. I had issues everytime I upgraded Wordpress with the plugin(s) I was using to do Markdown on it. This was part of the maintenance headache that I decided to remedy. 

Today I am writing my post on [Dillinger](https://dillinger.io/) running in a Docker container. I will save the post to my github repo, and push it. [Travis CI](https://travis-ci.com/) will pull the updates, and build the pages and push them back to GitHub on the master branch. 

I know that seems like a lot of additional work, but it really is not. I can also test my [Jekyll](https://jekyllrb.com/) pages locally using a Docker container to do the building to see what the final product is going to look like.

```sh
docker container run -it --rm -p 4000:4000 -v $PWD:/blog ruby:2.6.6 /bin/bash
```
Where the $PWD is the checked out blog. I set up an alias called `docker-blog` in zsh to run the container. Once the container is started, I go to the `/blog` directory and run the following:
```sh
cd /blog && \
gem install bundler jekyll && \
bundle install && \
bundle exec jekyll serve
```
That completes my local environment to blog until I am sure I like it and commit.
