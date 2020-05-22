---
layout: post
cover: 'assets/images/pexels-photo-279844.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: Netty and JAX-RS (Jersey)
date: 2018-09-15 15:21:52.000000000 +00:00
categories: jyeary
tags: java web
subclass: 'post tag-java tag-web'
---
### Introduction

Netty and Jersey are a great combination for providing RESTful web services based on JAX-RS. Netty is designed for high-throughput, and Jersey is designed for ease of use. The example application below is an attempt to make demonstrate how to use these powerful technologies in short order.

### Code

The following class can be re-used in your personal projects in in a simple manner.

```java
package com.bluelotussoftware;

import io.netty.channel.Channel;
import java.net.URI;
import org.glassfish.jersey.netty.connector.NettyConnectorProvider;
import org.glassfish.jersey.netty.httpserver.NettyHttpContainerProvider;
import org.glassfish.jersey.server.ResourceConfig;

/**
 * A basic implementation of {@link NettyConnectorProvider} providing HTTP and HTTP/2 servers for the {@link URI} and
 * resource classes provided.
 *
 * @author John Yeary &lt;jyeary@bluelotussoftware.com&gt;
 * @version 1.0.0
 */
public final class NettyServerProviders {

    /**
     * Initializes a {@link NettyHttpContainerProvider} using the provided {@link URI} and resource classes with HTTP
     * 1.1.
     *
     * @param baseURI The base URI to connect to the server.
     * @param classes The resource classes to provide serve using this provider.
     * @return A initialized Netty {@link Channel}.
     */
    public static Channel initializeNettyHttpServer(final String baseURI, final Class&lt;?&gt;... classes) {
        final ResourceConfig rc = new ResourceConfig(classes);
        return NettyHttpContainerProvider.createServer(URI.create(baseURI), rc, false);
    }

    /**
     * Initializes a {@link NettyHttpContainerProvider} using the provided {@link URI} and resource classes with HTTP/2.
     *
     * @param baseURI The base URI to connect to the server.
     * @param classes The resource classes to provide serve using this provider.
     * @return A initialized Netty {@link Channel}.
     */
    public static Channel initializeNettyHttp2Server(final String baseURI, final Class&lt;?&gt;... classes) {
        final ResourceConfig rc = new ResourceConfig(classes);
        return NettyHttpContainerProvider.createHttp2Server(URI.create(baseURI), rc, null);
    }

}
```

The implementation is just as easy.

```java
final Channel httpServer = NettyServerProviders.initializeNettyHttpServer(BASE_URI_HTTP, HelloResource.class);
```

As you can see, we are providing it with a single resource class called **HelloResource.class**. However, the **NettyServerProviders.class** accepts an array of resource classses, so you can simply just add them as necessary,e.g.,`final Channel httpServer = NettyServerProviders.initializeNettyHttpServer(BASE_URI_HTTP, HelloResource.class, Resource2.class, Resource3.class, Resource4.class);`

### Project

The application can be downloaded from Github here: [jersey-netty-service](https://github.com/jyeary/jersey-netty-service).
