---
layout: post
cover: 'assets/images/pexels-photo-279844.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: JAX-WS on Tomcat
date: 2018-11-09 11:18:37.000000000 +00:00
categories: jyeary
tags: java
subclass: 'post tag-java'
---
### Introduction

I was recently tasked with looking into an issue on Embedded Apache Tomcat 8 where a JAX-WS service was installed. It looks like the services were originally written for Java 5 and JAX-WS 2.1. Before making any changes to the existing implementation, I wanted to check on the latest versions and see what might be different and cause a conflict. I know that the JRE includes later versions of JAX-WS and thought that might be the source of the issue. It turns out that it was not. It was something completely different. However, the exploration into how to make JAX-WS work on Embedded Apache Tomcat 8 was still worth publishing.

### Embedded Tomcat

I have a number of projects on Github for Apache Tomcat. They can be found in the list below:
* [tomcat-8-jaxws](https://github.com/jyeary/tomcat-8-jaxws) - This example.
* [tomcat-8-embedded](https://github.com/jyeary/tomcat-8-embedded)
* [tomcat-9-embedded](https://github.com/jyeary/tomcat-9-embedded)
* [tomcat-security-valves](https://github.com/bluelotussoftware/tomcat-security-valves) - If you are using embedded Tomcat and you want to be secure, you should look at these valves. They are also published on Maven Central and available in Maven.


The code for our example using JAX-WS will be using a war file with a simple JAX-WS service that returns the current date.

```java
package com.bluelotussoftware.tomcat.embedded;

import java.io.File;
import javax.servlet.ServletException;
import org.apache.catalina.Host;
import org.apache.catalina.LifecycleException;
import org.apache.catalina.startup.Tomcat;

/**
 * An Example Embedded Apache Tomcat with an JAX-WS service 
 *
 * @author John Yeary <jyeary@bluelotussoftware.com>
 * @version 1.0.0
 */
public class Main {

    /**
     * Main method.
     *
     * @param args command line arguments passed to the application. Currently unused.
     * @throws LifecycleException If a life cycle exception occurs.
     * @throws InterruptedException If the application is interrupted while waiting for requests.
     * @throws ServletException If the servlet handling the response has an exception.
     */
    public static void main(String[] args)
            throws LifecycleException, InterruptedException, ServletException {
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(8080);
        tomcat.setBaseDir("target/tomcat");
        Host host = tomcat.getHost();
        host.setAppBase(".");
        host.setAutoDeploy(true);
        host.setDeployOnStartup(true);
        File ws = new File("src/test/resources/simple-jaxws-1.0.0.war");
        tomcat.addWebapp(host, "", ws.getAbsolutePath());
        tomcat.start();
        tomcat.getServer().await();
    }
}
```

This will start the application when you run it on (http://localhost:8080) and sets the default application to the base directory. It is very simple to setup and use.

### SimpleService

The service that is exposed can be found in the [simple-jaxws](https://github.com/jyeary/simple-jaxws) project. It requires a couple of files like *sun-javaws.xml* and the actual service. Since the application is running on a Servlet 3.0+ based server it does not require a *web.xml* file.

#### sun-javaws.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<endpoints version="2.0" xmlns="http://java.sun.com/xml/ns/jax-ws/ri/runtime">
  <endpoint implementation="com.bluelotussoftware.example.Simple" name="SimpleService" url-pattern="/*"/>
</endpoints>
```

#### Simple.java

```java 
package com.bluelotussoftware.example;

import java.util.Date;
import javax.jws.WebMethod;
import javax.jws.WebService;

/**
 * A simple service that returns the current date when called.
 *
 * @author<a href="mailto:jyeary@bluelotussoftware.com">John Yeary</a>
 * @version 1.0.0
 */
@WebService
public class Simple {

    /**
     * This operation returns the current date when it was run.
     *
     * @return current date.
     */
    @WebMethod(operationName = "getCurrentDate")
    public Date getCurrentDate() {
        return new Date();
    }
}
```

### Summary

Implementing a JAX-WS service on embedded Apache Tomcat is simple to do. Using this techique will allow you to write unit tests (integration tests) that can improve your code quality.
