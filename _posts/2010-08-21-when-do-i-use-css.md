---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2010-08-21 21:19:00+00:00
title: When Do I Use CSS?
categories: jyeary
tags: web
subclass: 'post tag-web'
---
{% include image.html url='http://upload.wikimedia.org/wikipedia/commons/thumb/8/86/CSS.svg/275px-CSS.svg.png' caption='A graphical depiction of a very simple css doc' %}

I have been looking at a number of articles on web technologies, and [HTML](http://en.wikipedia.org/wiki/HTML). One of the things I noticed on a lot of the examples is the lack of [Cascading Style Sheets](http://en.wikipedia.org/wiki/Cascading_Style_Sheets) (CSS) usage. Let me try to help... Here are three simple reasons.

The basic principle, especially if you are generating pages, is to use the [Don't Repeat Yourself](http://en.wikipedia.org/wiki/Don%27t_repeat_yourself) (DRY) principle. Do you want to change every warning message, individually if the font changes?

1. Always Use Cascading Style Sheets
    People are fickle. People want consistency; that is why McDonald's is so popular. If you want to change the font for a whole site to a user provided font, you would need to alter every <font/> tag to modify a change. Using CSS you can easily set the font for the whole site. Suppose you want to change all <h2/> tags to be italic, font to be Fantasy, and font size large. You could use a find, and replace to make the changes, **EVERY** time you needed to make a change, or use CSS.

    ```
    h2 {
        font-style: italic;
        font-family: fantasy;
        font-size: large;
    }
    ```

    I think we can all agree that was easier.
2. Grouping is Easier
    If I want to change an error message to print in the footer of my page, and to display with a larger font, font-weight, and color. Using a CSS is much easier than setting the tags on every element in the footer. This allows me to format error messages, for example, a different way in the body of the document. An example would be general validation errors like last name as a required field vs. a product in your shopping cart is not available.
    
    ```
    .warning {
        font: bold;
        font-size: medium;
        color: red;
    }
    #footer .warning {
        font-size: xx-large;
        font-weight: bolder;
        color: orangered;
    }
    ```
3. Overriding an Existing Style is Easy
    If I set the default font for the site to a particular font, I can easily **override** it by changing the tag, or location (group) to reflect a more specific style. This is the cascading part...
    
    ```
    body {
        font-family: Arial;
    }
    h1 {
        font-family: Sans-Serif;
        font-weight: bolder;
        font-size: x-large;
    }
    ```

I hope that explains why Cascading Style Sheets (CSS) are helpful.