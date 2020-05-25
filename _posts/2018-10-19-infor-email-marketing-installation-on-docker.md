---
layout: post
cover: 'assets/images/cover4.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-10-19 16:23:09+00:00
title: Infor Email Marketing Installation on Docker
categories: jyeary
tags: java
subclass: 'post tag-java'
---
### Centos (Open Source RHEL)
1. `docker pull centos:7`
2. `docker run -d -it --name email-marketing -p 8080:8080 -p 8443:8443 -p 1527:1527 -p 25:25 -p 113:113 -p 443:443 -p 80:80 -p 8085:8085 -p 44385:44385 centos:7`

Here is my version of the command which sets the custom private bridge network and host name.
  
```
docker run -d -it --name email-marketing -p 8080:8080 -p 8443:8443 -p 1527:1527 -p 25:25 -p 113:113 -p 443:443 -p 80:80 -p 8085:8085 -p 44385:44385 -h em.vm.lotus.bluelotussoftware.com  --network 10.0.3.x-bridge centos:7
```
3. Connect to centos instance via `Exec` on Kitematic.
4. `/bin/bash` to create a BASH prompt.
5. (OPTIONAL) `yum update`. Agree to any packages and wait for it to complete.
6. (OPTIONAL) Restart centos instance in Kitematic.
7. `yum install java-1.7.0` to install OpenJDK 7 JRE. Agree to any packages and wait for it to complete.
8. (ALTERNATIVE) If you want to install the OpenJDK 7 (JDK), use this command instead `yum install java-1.7.0-openjdk-devel`
9. `java -version` should indicate something similar to this:
  > java version "1.7.0_181"
  > OpenJDK Runtime Environment (rhel-2.6.14.5.el7-x86_64 u181-b00)
  > OpenJDK 64-Bit Server VM (build 24.181-b00, mixed mode)
10. Copy the Email Marketing `install.bin` file to the centos instance using `docker cp install.bin email-marketing:/`.
11. Install Email Marketing using the defaults. Don't install SSL since we don't have a certificate yet.
12. Start the outgoing service and configure DNS.
  > **NOTE:** You must have a DNS server configured with the IP address already. If you are working in the Infor 
  > environment this should already be set for your machine, e.g. _usgvdjyeary01.em.infor.com_.
13. Copy the _keystore.jks_ file to the server which contains the key we will use for SSL/TLS. `docker cp keystore.jks email-marketing:/root/INFOR/EM/config`
14. Modify the configuration on the server to use your keystore and configure SSL/TLS. Ensure if you are using a self-signed certificate, that you install the certificate in the trusted keystore (cacerts) which is located in **/etc/alternatives/jre/lib/security**

### Private Network
I set up a private network (VLAN) for my environment in Docker. I did this to make it easier to setup DNS (bind). Listed below are some parameters you will need for a private network.
```
# Set the default_bridge to false unless you want this to be your default network.
com.docker.network.bridge.default_bridge=false
com.docker.network.bridge.enable_icc=true
com.docker.network.bridge.enable_ip_masquerade=true
com.docker.network.bridge.host_binding_ipv4=0.0.0.0
# The bridge.name be unique
com.docker.network.bridge.name=docker1
com.docker.network.driver.mtu=1500
```
