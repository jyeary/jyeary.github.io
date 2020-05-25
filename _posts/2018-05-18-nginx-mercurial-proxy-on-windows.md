---
layout: post
cover: 'assets/images/pexels-photo-158935.jpeg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-05-18 03:02:30+00:00
title: NGINX Mercurial Proxy on Windows
categories: jyeary
tags: web
subclass: 'post tag-web'
---
In my previous article I explained how to setup [Mercurial 4.5+ as a Windows Service](/2018-05-16-mercurial-4-5-as-a-windows-service.html). In this article we will expand on that configuration, and use NGINX to proxy to the service.

**Note:** This is supposed to make the service faster. However in my testing, I found it slower. This does allow you to use other functionality like LDAP, and AD authentication which is not available to our Mercurial service.

### Requirements
* Install Mercurial as a Windows Service as detailed in this article :  [Mercurial 4.5+ as a Windows Service](/2018-05-16-mercurial-4-5-as-a-windows-service.html).
* Download [NGINX for Windows](http://nginx.org/en/download.html). The current version at the time of this article is 1.13.12.
* [winsw-v2.1.2](https://github.com/kohsuke/winsw/releases) (Please select the version according to .Net version installed on your platform).

### Installation
1. I am partial to installing the nginx server by unzipping the file to  _C:\nginx-1.13.12_. This helps us to avoid any path related issues.
2. Next, we will install the WinSW file to the nginx directory.
3. Rename the WinSW executable to `nginx-service.exe`.
4. Create an XML file called **nginx-service.xml**. Modify it as shown below.
5. Run `nginx-service.exe install` to install the service
6. The _conf/nginx.conf_ needs to be modified to point to our mercurial service. You will need to modify `server_name` and `listen` to match your environment. Please see the example below.
7. The Mercurial service we installed earlier is set to startup and listen on all IP interfaces by default (0.0.0.0). We want to modify this to bind to localhost. This will prevent the service from being exposed except through our NGINX. This is accomplished by changing the line in the `hg-service.bat` to the following: `"C:\Python27\Scripts\hg.exe" serve --address localhost --web-conf C:\hg\hgweb.config`
8. Start the service and enjoy.

#### nginx-service.xml
```xml
<service>
    <id>nginx</id>
    <name>nginx</name>
    <description>nginx web server.</description>
    <depend>hg-serve</depend>
    <executable>nginx.exe</executable>
    <stopexecutable>nginx.exe</stopexecutable>
    <stopargument>-s</stopargument>
    <stopargument>quit</stopargument> 
    <logmode>rotate</logmode>
    <logpath>C:\nginx-1.13.12\logs</logpath>
</service>
```

#### nginx.conf
We need to add a location to the file to proxy the connection to our Mercurial service.

```
worker_processes 1;
events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 8080;
        server_name 10.0.2.15;

    location / {
        proxy_pass http://localhost:8000;
        }

        error_page 500 502 503 504  /50x.html;
        location = /50x.html {
            root html;
        }
    }

#    server {
#        listen 443 ssl;
#        server_name 10.0.2.15;

#        ssl_certificate server.pem;
#        ssl_certificate_key server.key;

#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout 5m;

#        ssl_ciphers HIGH:!aNULL:!MD5;
#        ssl_prefer_server_ciphers on;

#   location / {
#       proxy_pass http://localhost:8000;
#       }
#   }
}
```

![Mercurial on NGINX](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/05/nginx-mercurial-services-running.jpg)
