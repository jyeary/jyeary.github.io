---
layout: post
cover: 'assets/images/door-green-closed-lock.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-05-25 15:30:39+00:00
title: CFSSL Cloudflare SSL
categories: jyeary
tags: web
subclass: 'post tag-web'
---
A normal devops activity is installing certificates on your servers. However, most servers if used internally don't need an official CA signed certificate for normal operations. Especially when dealing with development machines, or testing. So why pay the man... when you can be the man! Be your own CA!

### Cloudflare SSL (cfssl)
Cloudflare open-sourced their cfssl software under a BSD license. It is written in go, and offers a number of great features. However, like any number of open-source projects, it lacks really good documentation. The software works great once you get it figured out. Let me try to show you how I set up my configuration.

#### Bootstrap Instructions
1. Create a Certificate Authority (CA) Certificate Signing Request (CSR). This is the file used to generate our CA name, keys, and generate our own CSR (if we want it signed by another CA). Here is an example **ca_csr.json**.
```json
{
  "CN": "Internal CA",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Greenville",
      "O": "Charlie Company",
      "OU": "OPS",
      "ST": "South Carolina"
    }
  ]
}
```
2. Generate your public and private keys, and a CSR for signing by a third party if necessary.
```
cfssl gencert -initca csr_ca.json | cfssljson -bare ca
```
3. Create your configuration file **ca_config.json**. My version differs from the first reference listed below. You will need to provide your own key. Here is an online resource to generate one: [Random Byte Generator](https://www.random.org/bytes/)
```json
{
  "signing": {
    "default": {
      "auth_key": "key1",
      "expiry": "8760h",
      "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "cert sign",
          "crl sign",
          "client auth"
        ]
      }
  },
  "auth_keys": {
    "key1": {
      "key": <16 byte hex API key here> ,
      "type": "standard"
    }
  }
}
```
4. Start your server:
```
cfssl serve -ca-key ca-key.pem -ca ca.pem -config config_ca.json
```

### Generating and Signing Certificates
**Note:** The server name in this example is called _groot_, as in, _I am Groot!_ from the movie _Guardians of the Galaxy_.

1. Create Create a **csr_client.json**. This contains the information for the server for which we want create a certificate.
```json
{
  "CN": "groot.example.com",
  "hosts": [
      "iamgroot.example.com",
      "*.example.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Greenville",
      "O": "Charlie Company",
      "OU": "OPS",
      "ST": "South Carolina"
    }
  ]
}
```
2. Create a **config_client.json**. This contains the information required to connect to our new server.
```json
{
  "signing": {
    "default": {
      "auth_remote": {
      "auth_key": "key1",
      "remote": "caserver"
    }
  }
  },
  "auth_keys": {
    "key1": {
    "key": "<16 byte hex API key here. Same key as server.>",
    "type": "standard"
    }
  },
  "remotes": {
    "caserver": "127.0.0.1"
  }
}
```
3. The command below will generate the key (**groot-key.pem**), and CSR (**groot.csr**). Then it will use the provided configuration to contact the server and return the signed certificate. The certificate will be called **groot.pem**.
```
cfssl gencert -config config_client.json csr_client.json | cfssljson -bare groot
```
4. (ALTERNATIVE) If you already have a CSR, you can request that the server sign it. This will provide a certificate called **groot.pem**
```
cfssl sign -config config_client.json groot.csr | cfssljson -bare groot
```
5. (ALTERNATIVE) If you need additional host names, e.g, Subject Alternative Name (SAN), you can use the following command substituting hostnames below with comma separated values.
```
cfssl sign -config config_client.json -hostname=quill.example.com,ronan.example.com,kree.example.com groot.csr | cfssljson -bare groot
```

### References
* [How to build your own public key infrastructure](https://blog.cloudflare.com/how-to-build-your-own-public-key-infrastructure/)
* [cloudflare/cfssl](https://github.com/cloudflare/cfssl)
* [steps in bootstrap.txt not working #566](https://github.com/cloudflare/cfssl/issues/566)