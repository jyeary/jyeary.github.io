---
layout: post
cover: 'assets/images/pexels-photo-239898.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: j2html framework
date: 2018-09-15 15:50:14.000000000 +00:00
categories: jyeary
tags: java web
subclass: 'post tag-java tag-web'
---
I had my first exposure to this fun and easy to use framework in Java Magazine - [j2html: An HTML5 Generator Library](http://www.javamagazine.mozaicreader.com/JulyAugust2018/facebook#&amp;pageSet=27&amp;page=0&amp;contentItem=0"). I have to say that it is slick and easy for the most part. The more HTML you use... the more complex it becomes. However, if you need to output an error page, a login page on the fly, or simple pages to display information, this framework is hard to beat.

This example is from Java Magazine... You really need to read the well written article.
```java
package com.example;

import static j2html.TagCreator.*;
import j2html.tags.Tag;

public class Example3 {

    public static void main(String[] args) {
        String output = form()
                .withMethod("post")
                .with(
        genericInput("text", "username", "Enter your Username"),
        genericInput("password", "password", "Enter your password"),
        submitButton())
                .renderFormatted();
        System.out.println(output);
    }

    private static Tag genericInput(String type, String name, String placeholder) {
        return input()
                .withType(type)
                .withId(name)
                .withPlaceholder(placeholder)
                .isRequired();
    }

    private static Tag submitButton() {
        return button("Login").withType("submit");
    }
}
```
A login page done programmatically. How slick is that? Read the article and share the love.
