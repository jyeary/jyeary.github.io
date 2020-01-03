---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: 'Java Tip of the Day: StandardCharsets'
date: 2018-09-20 12:00:33.000000000 +00:00
categories: jyeary
tags: java
subclass: 'post tag-java'
---
## Introduction

It is important to look at other people's code. It often gives us
insight into undiscovered content and ideas that we can put into our own
toolbox of code.

We do a lot of the same coding over and over on different projects.
Often because we don't have a common framework to share between
projects, or we don't want to include a framework into a project just to
use one, or two classes from it. It is often better to find code which
is part of Java itself, or a must have framework that is included in our
projects, e.g. Apache Commons XXX.

Yesterday, I was looking at a unit test and saw the following:

```java
    StandardCharsets.UTF_8.name();
```
I paused and asked myself what is that? When I opened it in NetBeans, I
realized that I had missed a piece of code from Java 7 that could make
my life easier.

I often find that I am using a String to set the value for "UTF-8", or
setting the Charset and wrapping it to catch any exceptions. Some

## StandardCharsets

This
[StandardCharsets](https://docs.oracle.com/javase/10/docs/api/java/nio/charset/StandardCharsets.html)
class is in the JRE starting with Java 7 and as noted in the Javadoc:

> Constant definitions for the standard Charsets. These charsets are
> guaranteed to be available on every implementation of the Java
> platform.

Now you can skip having to create your own code and use the standard
Java class which is guaranteed to exist.

> $ jshell | Welcome to JShell -- Version 10.0.2 | For an introduction
> type: /help intro
> 
> jshell\> import java.nio.charset.StandardCharsets;
> 
> jshell\> System.out.println(StandardCharsets.UTF\_8.name());
> 
> UTF-8

## Conclusion

Though this may not bring about world peace, or even get you a cup of
coffee, it is a nice little piece of code when you need it in a pinch.

```java 
try (ByteArrayOutputStream baos = ...) { System.out.println(baos.toString(StandardCharsets.UTF_8.name()));
}
```