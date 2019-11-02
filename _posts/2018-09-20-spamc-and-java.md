---
layout: post
cover: 'assets/images/2018_09_506px-Spam_can-300x285.png'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-09-20 20:45:12+00:00
title: SPAMC and Java
categories: jyeary
tags: java
subclass: 'post tag-java'
---
## Introduction

I was tasked with trying to find a quick way to test if a SpamAssassin server was running. The idea was that we needed to not only check it, but if there was a framework out there that would make it simple.

In fact, we had developed our own framework over time by various developers with different approaches. However, I would like to replace it with something that will work for us that was designed from the bottom up as an implementation of SPAMC for Java. I thought it might be something I would end up writing, but alas I found one that is well written and easy to use.

## spamc

[spamc](https://github.com/alphabox/spamc) written by Daniel Mecsei at Alphabox does the job. It is an F/OSS framework that makes communicating with SpamAssassin extremely easy. The Github project has an example that I won't repeat here, but trust me, it is easy to implement and use.

## As for me...

I needed to test the service and wrote a quick implementation that worked something like this.
```java
    package com.example.spamc.client;
    
    import hu.alphabox.spamc.SAClient;
    import hu.alphabox.spamc.SACommand;
    import hu.alphabox.spamc.SARequest;
    import hu.alphabox.spamc.SAResponse;
    import org.junit.Test;
    import static org.junit.Assert.*;
    
    public class SPAMCTest {
    
        public SPAMCTest() {
        }
    
        @Test
        public void testPong() throws Exception {
            SARequest saRequest = new SARequest();
            saRequest.setCommand(SACommand.PING);
            saRequest.setMessage("");
            SAClient client = new SAClient("localhost", 783);
            SAResponse response = client.sendRequest(saRequest);
            String expected = "SPAMD/1.5 0 PONG\r\n";
            System.out.println(response.getHeaders());
            assertEquals(expected, response.getHeaders());
        }
    }
```
