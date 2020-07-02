---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2020-07-03 16:07:00+00:00
title: CORS Bean Configuration in Spring
categories: jyeary
tags: java
subclass: 'post tag-java'
---

I was working on an application today trying to setup CORS in Spring 2.1.8 (I know its an older version of Spring) and it would not work. It turns out I needed to update it to at least 2.2.0. Along the way, I was not able to find really good examples of how to setup customized handlers. Here is an example which allow simple defaults.

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

@Configuration
public class ApplicationConfiguration  {

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration().applyPermitDefaultValues();
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public CorsFilter corsFilter() {
        return new CorsFilter(corsConfigurationSource());
    }
}
```