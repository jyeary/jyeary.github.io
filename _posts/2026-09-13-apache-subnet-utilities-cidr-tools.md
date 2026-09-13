---
layout: post
cover: 'assets/images/pexels-muhammad-amdad-hossain-39171178.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2026-09-13 09:00:00+00:00
title: "Apache Subnet Utilities: CIDR Tools"
categories: [jyeary]
tags: [java]
subclass: 'post tag-java'
---

I was looking for some utilites to handle subnet CIDR addressing for an application I was developing. I had some very basic requirements: simple to use, and simple to maintain. My go to for those kind of necessary utilities is to immediately look for an Apache Commons utility frameworks. In my case, the solution was found in the [Apache Commons Net](https://commons.apache.org/proper/commons-net/). They provide a class called `SubnetUtils` which convieniently takes a CIDR notation based string constructor. This was actually a perfect match for me. The network device I am receiving events from emits the data in CIDR notation that Apache is expecting. Bonus for the handling the data in the format that is emitted. The result is an `SubnetUtils.SubnetInfo` object which has all of the convenience methods I needed to fetch the network information. Here is an example:

```java
package com.example.apache.commons.net;

import org.apache.commons.net.util.SubnetUtils;

/**
 *
 * @author John Yeary
 */
public class ApacheCommonsNetSubnetUtils {

    public static void main(String[] args) {
        String cidr = "200.200.200.5/22";
        System.out.println("CIDR input: " + cidr);

        SubnetUtils.SubnetInfo info = new SubnetUtils(cidr).getInfo();

        System.out.println(info);
        System.out.println("Network Address: " + info.getNetworkAddress());
        System.out.println("CIDR Signature: " + info.getCidrSignature());
        System.out.println("Low Address: " + info.getLowAddress());

        info = new SubnetUtils("200.200.200.5", "255.255.252.0").getInfo();

        System.out.println(info);
        System.out.println("Network Address: " + info.getNetworkAddress());
        System.out.println("CIDR Signature: " + info.getCidrSignature());
        System.out.println("Low Address: " + info.getLowAddress());
    }
}
```
The results:

```shell
CIDR input: 200.200.200.5/22
CIDR Signature:	[200.200.200.5/22]
  Netmask: [255.255.252.0]
  Network: [200.200.200.0]
  Broadcast: [200.200.203.255]
  First address: [200.200.200.1]
  Last address: [200.200.203.254]
  Address Count: [1022]

Network Address: 200.200.200.0
CIDR Signature: 200.200.200.5/22
Low Address: 200.200.200.1
CIDR Signature:	[200.200.200.5/22]
  Netmask: [255.255.252.0]
  Network: [200.200.200.0]
  Broadcast: [200.200.203.255]
  First address: [200.200.200.1]
  Last address: [200.200.203.254]
  Address Count: [1022]

Network Address: 200.200.200.0
CIDR Signature: 200.200.200.5/22
Low Address: 200.200.200.1
```

If you need to find utilties to perform actions in your code, you should look to Apache to see if they have what you need, or maybe you can contribute your solution to Apache for others.

---

*Cover photo: ["Aerial view of workers in red chili field"](https://www.pexels.com/photo/aerial-view-of-workers-in-red-chili-field-39171178/)
by [Muhammad Amdad Hossain](https://www.pexels.com/@muhammad-amdad-hossain-2163573768/) on Pexels.*