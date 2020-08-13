---
layout: post
cover: 'assets/images/pexels-magda-ehlers-985266.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2020-08-13 17:00:00+00:00
title: "Spring: How to Redirect the Context Root to Open API 3.0 (Swagger) UI"
categories: jyeary
tags: java
subclass: 'post tag-java'
---

I needed to set up my REST application to redirect users to my Open API Specification 3.0 (Swagger) UI in Spring. This can easily be accomplished by adding the following `@Controller` to the project.
```java
package com.example.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Root context redirection to OpenAPI API Specification (OAS) documentation.
 *
 * @author John Yeary <jyeary@bluelotussoftware.com>
 * @version 1.0.0
 */
@Controller
public class OASController {

    /**
     * Sets the index page mapping to point to the Swagger UI.
     *
     * @return A redirect to the Swagger UI.
     */
    @RequestMapping("/")
    public String index() {
        return "redirect:swagger-ui.html";
    }

}
```