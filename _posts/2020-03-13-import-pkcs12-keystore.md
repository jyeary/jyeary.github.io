---
layout: post
cover: 'assets/images/photo-of-woodpile-1787035.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
title: 'Convert Server Certificate and Key into PKCS#12, and Java Keystore (JKS)'
date: 2020-03-13 12:00:00.000000000 +00:00
categories: jyeary
tags: java
subclass: 'post tag-java'
---

I was looking for simple instructions on how to convert a certificate to a keystore. Here is my simplified version.

1. Build the certificate chain into a single file.

```shell
cat server.pem intermediate.pem root.pem > import.pem
```

2. Convert the private key and merged certificate files into a PKCS12 file.

```shell
openssl pkcs12 -export -in import.pem -inkey server.key -name serverHostName > server.p12
```

3. Import the PKCS12 file into Java Keystore (JKS).

    **Note:** Java 9 changed the default Java Keystore to PKCS#12. The following is only required for Java 8, or applications that have JKS dependency. See [JEP 229: Create PKCS12 Keystores by Default](http://openjdk.java.net/jeps/229)

```shell
keytool -importkeystore -srckeystore server.p12 -destkeystore keystore.jks -srcstoretype pkcs12 -alias serverHostName 
```

### Notes

If you are using PKCS#12 as your keystore, edit the `JAVA_HOME/jre/lib/security/java.security` file and change the default keystore type as shown below:

```
# Default keystore type.
keystore.type=pkcs12
```