---
layout: post
cover: 'assets/images/bank-cash-cent-164552.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2019-11-01 00:00:00+00:00
title: Blog Migration
categories: jyeary
tags: web
subclass: 'post tag-web'
---
## Introduction

After a couple of years using Wordpress, I have found that constantly upgrading, broken plugins, managing a database, backups, and security certificates have brought me back to Github.

When I first started the blogging journey, I wanted a text editor which I could use to create my posts. Over the years, I have found myself using [Markdown](https://www.markdownguide.org/) at first for my Github projects, and finally for all of my work. This includes taking all my notes using Markdown.

I decided to come back and take a look at GitHub, and reconsider my previous position of it not being the right fit for me. Today, I think it is a perfect fit. The platform has been enhanced, and a number of great templates have been created to make using it a lot easier. That said, a number of the templates are **not** non-technical user friendly. I have had some challenges getting the blog back off the ground using Github, but I think that the final results will be worth it.

Over the next few weeks, I will begin the slow process of migrating the old blog pages over to Github, and adding new content. As I begin this journey, I will tell you how I did it.

## Decisions

If you are not comfortable in [Markdown](https://www.markdownguide.org/) then using Github pages are not for you. You have to decide if you want to learn it, and use it. Otherwise the risk is that you will **not** blog which is the opposite of your objective.

If you have a blog already, then you need to decide if you want to do the work to migrate it. This could be an enormous undertaking if you have been doing it for years. It also could be something that you may not want to do. I have another blog [Java Evangelist John Yeary](http://javaevangelist.blogspot.com/) which is quite large. I wrote it on Blogger, and decided that I **did not** want to move it. It was established, and profitible. I did decide years ago that I wanted to move it from a propietary platform and make it more "my own". Thus I created a blog simply called John Yeary. That is the blog we are going to be migrating. 


## First Steps

The first step in getting started in creating, or migrating a blog is to find a good template to use. You can go all-in on creating your own using, but even [jekyll](https://jekyllrb.com/) uses a basic template called *minima* when you create a simple site using the tutorial.

I chose a template based on the popular [ghost](https://ghost.org/blog/) platform called [Jasper](https://github.com/jekyller/jasper). There is another version called [Jasper 2](https://github.com/jekyller/jasper2), but I found the original Jasper version more my style.

The nice thing about choosing to use an open source template is that you are free to modify it to match your needs. This was not insurmountable in Wordpress, but much more challenging. I was also in fear of the template being upgraded that would make me have to figure out what changed, and if anything was broken. Since we are using a source control system (git) and we can control our own destiny with regards to upgrades, then the worries about template changes from Wordpress are no longer an issue.

Next, I would make sure that you understand what the templates do and how they are configured. The [Jekyll Quickstart](https://jekyllrb.com/docs/) is very good. It will give you a great foundation on how Jekyll generates the pages, and displays them.

In my case I chose to use [Jasper](https://github.com/jekyller/jasper) for my templates. This template uses plugins to generate additional functionality on the pages, as a result it can not be used directly for generating my pages from Github. In this case, I am using [Travis CI](https://travis-ci.com/) to build the the pages and push the changes from a development branch to the `master` branch since this is the branch which is used to deploy the pages. In my case it is only merging the `_site` data.

## Migrating Existing Pages

There are a number of mechanisms to import existing blog formats into Jekyll. They can be found on the [Jekyll Import Documentation](https://import.jekyllrb.com/docs/home/). I am migrating from Wordpress so I tried a couple of different mechanisms. Although, it mentions the Wordpress.com importers for use with the online site, I found them to be useful on the self-hosted variety I was using. The best one after trying them all was [Exitwp](https://github.com/thomasf/exitwp).

I found that not just one tool worked for me, and I am going to have to use multiple results and merge them to get the pages migrated. 