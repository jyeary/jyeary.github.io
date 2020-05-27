---
layout: post
cover: 'assets/images/black-and-white-photo-of-a-building-3914752.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2020-05-26 21:13:48+00:00
title: cfssl Intermediate and Client Certificates
categories: jyeary
tags: web
subclass: 'post tag-web'
---
### Introduction
In a previous blog post [CFSSL Cloudflare SSL](/2018-05-25-cfssl-cloudflare-ssl.html) I discussed how to setup `cfssl` as a Certification Authority (CA) for issuing your own certificates. This becomes increasingly important in the world of containers. Especially when those containers are on internal networks, and VPCs where getting a [Let's Encrypt](https://letsencrypt.org/) certificate is not possible, or desirable.

### New and Improved
I was looking for a way to set up intermediate and client certificates. I was looking for ideas on how to setup the CA to handle these additional certificates. I found a post by Johannes Tegnér<sup>1</sup>. I liked his layout idea which I slighly modified below.
```sh
/CA
    /root
    /intermediate
        /production
        /development
    /certs
```
I tried his using the files he provided, but I believe that `cfssl` was updated between his post and today. As a result, the `config.json` files would not work without slight modifications. Here is my `config.json` for intermediate certificates. This file goes in the `intermediate` directory.
```xml
{
    "signing": {
        "default": {
            "expiry": "720h",
            "usages": [
                "signing",
                "key encipherment",
                "cert sign",
                "crl sign"
            ]
        },
        "profiles": {
            "development": {
                "ca_constraint": {
                    "is_ca": true,
                    "max_path_len": 0,
                    "max_path_len_zero": true
                },
                "expiry": "2160h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "cert sign",
                    "crl sign"
                ]
            },
            "production": {
                "ca_constraint": {
                    "is_ca": true,
                    "max_path_len": 0,
                    "max_path_len_zero": true
                },
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "cert sign",
                    "crl sign",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
```
The intermediate certificates can be created with the following commands without using the network configuration in my previous blog post.
```sh
cd CA/intermediate/development
cfssl genkey -initca ../intermediate.json | cfssljson -bare development
cfssl sign -ca ../../root/ca.pem -ca-key ../../root/ca-key.pem --config ../config.json -profile development  development.csr | cfssljson -bare development 
```
Here is my `config.json` for different usage profiles for the final certificates.
```xml
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "digital signature",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "digital signature",
                    "key encipherment",
                    "client auth",
                    "server auth"
                ]
            },
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "digital signing",
                    "key encipherment",
                    "server auth"
                ]
            }
        }
    }
}
```
The final step for my purposes was generating the client certs.
Here is my `client.json` file which is the same as Johannes' file. His explanation is worth quoting.
> When it comes to the client certificate, we don’t set any hosts, as we want to be able to
> connect to the services without having to care about the clients current host. It’s okay 
> to do though, if you want to!

```xml
{
    "CN": "Client",
    "hosts": [
        ""
    ]
}
```

```sh
cfssl gencert -ca ../intermediate/production/production.pem -ca-key ../intermediate/production/production-key.pem -config=config.json -profile=client client.json | cfssljson -bare client
```

### References
1. [Certificate Authority with CFSSL ](https://jite.eu/2019/2/6/ca-with-cfssl/)
2. [CFSSL\: Cloudflare's PKI and TLS toolkit](https://github.com/cloudflare/cfssl)