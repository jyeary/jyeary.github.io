---
layout: post
cover: 'assets/images/pexels-eric-hammett-2989658.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2021-01-15 00:00:00+00:00
title: Running Kibana on Docker
categories: jyeary
tags: web
subclass: 'post tag-web'
---

There are a number of documents on how to run Kibana on Docker using a `docker-compose` file. The instructions from Elastic have you create a link, but there is nothing as simple as the commands below.

```
docker container run -d --rm -e ELASTICSEARCH_HOSTS=https://{YOUR_SERVER_IP_HERE}:9200 -p 5601:5601 docker.elastic.co/kibana/kibana:7.10.0
```

This will create an instance of Kibana that is removed when you are done with it. You just need to replace the `{YOUR_SERVER_IP_HERE}` with the IP address or DNS name of the server, e.g. localhost.

If you need to provide a custom `kibana.yml`, you can create the files locally and bind mount them as shown below. 

### Powershell Example

```
docker container run -d --rm -e ELASTICSEARCH_HOSTS=https://{YOUR_SERVER_IP_HERE}:9200 -v ${PWD}/kibana/:/usr/share/kibana/config/ -p 5601:5601 docker.elastic.co/kibana/kibana:7.10.0
```

### MacOS/Linux/UNIX Example

```
docker container run -d --rm -e ELASTICSEARCH_HOSTS=https://{YOUR_SERVER_IP_HERE}:9200 -v $(PWD)/kibana/:/usr/share/kibana/config/ -p 5601:5601 docker.elastic.co/kibana/kibana:7.10.0
```