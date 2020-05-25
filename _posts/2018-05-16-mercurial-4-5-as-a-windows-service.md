---
layout: post
cover: 'assets/images/pexels-photo-963635.jpeg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-05-16 20:49:59+00:00
title: Mercurial 4.5+ as a Windows Service
categories: jyeary
tags: web
subclass: 'post tag-web'
---
### Requirements:
* [Python 2.7.15](https://www.python.org/downloads/release/python-2715/)
* [Mercurial 4.5.3](https://www.mercurial-scm.org/downloads) (source install)
* [winsw-v2.1.2](https://github.com/kohsuke/winsw/releases) (Please select the version according to .Net version installed on your platform)

### Python
I used the MSI installer for Python. It works perfectly fine, and can be used in a headless environment like Windows Server Core if you need to install it in a headless environment.

### Mercurial
I used the Mercurial source install. This places the software within the Python installation. This makes it easier for applications to find it. If you use an installer like the Windows MSI, it will place the application in a different location such as `C\Program Files` 

I needed to be able to create a Windows Service for Mercurial. Unfortunately, there is no built-in functionality in the Mercurial Downloads, not even for Windows installers (.msi) files. This is not the end of the world. There are commercial products that you can purchase to accomplish this. In my day job, we have such a contract for one of those products. In the world of open source though we expect that we are not the first person to encounter such an issue. Fortunately, there is a great project called [WinSW](https://github.com/kohsuke/winsw). Kohsuke one of the original authors of Jenkins developed this code for use in that project, and released it for public consumption.

### WinSW
[WinSW](https://github.com/kohsuke/winsw) is one of the easiest software applications to use to make Windows services. You download the application, and rename it to whatever you  like. In this example, I used `hg-service.exe` since that made the most sense to me. The configuration file that is used must match the name of the service. That makes a lot of sense too. The WinSW software examines its own name, and looks for a configuration file with the same name and an .xml extension. You can see this in the example below. 

![Mercurial files](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/05/files.png)

### Installation and Configuration
1. Create a directory called `hg-service`.
2. Add the [winsw](https://github.com/kohsuke/winsw) file of your choice based on your .NET framework.
3. Rename the winsw file to `hg-service.exe`.
4. Add a blank `hg-service.xml` file. We will add details to it in a moment.
5. Add a blank `hg-service.bat` file. We will add details to it in a moment.

#### hg-service.bat 

Copy the following into the `hg-service.bat` file.

```shell
@echo off
if "%1"=="start" (goto :start)
:stop
taskkill /F /IM hg.exe /T
goto :end
:start
REM "C:\Python27\Scripts\hg.exe" serve --address localhost --port 8000 --web-conf C:\hg\hgweb.config
REM The configuration below will start the service on all addresses on the machine 0.0.0.0 on port 8000 by default
"C:\Python27\Scripts\hg.exe" serve --web-conf C:\hg\hgweb.config
:end
```    
#### hg-service.xml 
Copy the following into the `hg-service.xml` file. The details should be self-explanatory. If you need more details on the configuration file, please look at this post: [WinSW XML Configuration File](https://github.com/kohsuke/winsw/blob/master/doc/xmlConfigFile.md)

```xml
<service>
    <id>hg-serve</id>
    <name>Mercurial</name>
    <description>Mercurial Web Server.</description>
    <executable>cmd.exe</executable>
    <startargument>/c</startargument>
    <startargument>C:\hg\hg-service.bat</startargument>
    <startargument>start</startargument>
    <stopexecutable>cmd.exe</stopexecutable>
    <stopargument>/c</stopargument>
    <stopargument>C:\hg\hg-service.bat</stopargument>
    <stopargument>stop</stopargument>
    <logmode>rotate</logmode>
    <logpath>C:\hg\logs</logpath>
</service>
```    
#### hgweb.config 
Finally we need a configuration file that contains information about the repositories we want to serve. Here is an example configuration.
```ini   
[web]
encoding = UTF-8
allow_push = *
push_ssl = false
contact = John Yeary
allow_archive = gz zip bz2
descend = True
collapse = True
style=gitweb

[paths]
# Directory Search (Slow)
#/ = C:\repos\*
foo = C:\repos\foo
```    

This completes our installation as a service. As you can see our **Foo** is being served... 
{% include image.html url='https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/05/ServiceRunning.png' caption='Mercurial Service Running' %}

{% include image.html url='https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/05/FooMagick.png' caption='Mercurial Directory Listing' %}

The configuration files for this project are located here: **[hg-service.zip](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/05/hg-service.zip)**