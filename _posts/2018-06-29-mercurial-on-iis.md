---
layout: post
cover: 'assets/images/photo-of-white-eggs-on-tray-4110226.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-06-29 22:10:25+00:00
title: Mercurial on IIS
categories: jyeary
tags: web
subclass: 'post tag-web'
---
### Introduction
I was recently tasked with updating our Mercurial repository at work. The original repository and configuration using Apache had been in place for years without issues generally. The latest Apache versions for Windows are provided by third parties and not from Apache Foundation anymore.

When I looked at the configuration we were using, the Python FastCGI modules were very old and had not been updated in years. In fairness, they didn't need to be for our application, but there were no updates for the latest Apache HTTPD server. The existing third party versions of Apache didn't include the required libraries for the old modules. I didn't want to install everything required to compile a new version of Apache for our environment. This would add application maintenance overhead to me to maintain and update it. So what were my alternatives?

Since the application was already running on a Windows server, I decided to see if I could implement it on Windows without having to migrate to a Linux server. Although migrating to Linux, or UNIX would have been my preference, it was not available to me. The solution was to try to use IIS to serve up the application. Specifically, I had a set of requirements:
1. Windows AD authentication.
2. Mercurial needed to be available via HTTPS.
3. Latest version of Mercurial
4. Simple implementation
5. Easy maintenance

The ease of maintenance would be normal Windows server updates. The implementation should be sufficiently simple that a new ops, or engineer could be assigned the task of updating it, or maintaining it.

Since Mercurial is popular, I thought finding some details on deploying Mercurial on IIS would be simple. I found some blog posts and wiki pages on it, but they were very old. Nothing was up-to-date. So I decided to write my own post with details I gathered from multiple blog posts and references.

### Python
Install Python. I installed the **python-2.7.15.amd64.msi** on the server accepting the defaults except I also added Python to the path as shown below.

![Python Install](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/PythonInstall.png)

### Mercurial
Install Mercurial. I installed **mercurial-4.6.1.win-amd64-py2.7.msi** which will install it into the Python installation.

Once the installation is complete open a command prompt or Powershell and type _hg_. It should display a list of commands available.

### IIS
Install/activate IIS. We need to insure that CGI is enabled for wfastcgi.
1. Open **Server Manager**
2. Go to **Add Roles and Features**. Scroll down and select **Web Server (IIS)** and **Next**. Continue **Next** until you reach _Role Services_. 
  ![Add Remove IIS](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/AddRemoveIIS.png)
3. (OPTIONAL) Under **Performance**, select _Dynamic Content Compression_.
4. (OPTIONAL) Under **Security**, select any mechanism you want to use to allow users to connect. I selected _Basic Authentication_ and _Windows Authentication_. Click **Next**.
![Roles Services](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/RoleSevices.png)
5. Check options and click **Install**.
6. Once the install completes, we need to go back to **Add Roles and Features**. This time navigate to _Application Development_ and select _CGI_.
![CGI Enabled](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/CGIEnabled.png)

### Python FastCGI implementation (wfastcgi)
I looked for an implementation that would provide the sufficient capabilities to serve up the pages quickly with little overhead. I looked at a number of implementations. I was looking at wfastcgi and noticed that it was created and maintained by Microsoft. Bonus!

1. Using a command prompt or Powershell. type the following:
```
pip install wfastcgi
```
2. Once _pip_ finshes installing _wfastcgi_, run the following command to enable _wfastcgi_.
```
wfastcgi-enable     
```
![pip install](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/pipInstall.png)
3. After enabling _wfastcgi_, we can refresh our IIS Application Server Manager instance and we will have a new IIS management category called **FastCGI Settings**. Just confirm its presence we will attend to it shortly.
4. Next go to Sites in IIS Admin and ensure that you have the _Default Website_ stopped.
5. Right-click and **Add Website**. This will bring up a form to configure. I set my settings as shown below. You may change them to meet your needs.
![Add Website](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/AddWebsite.png)
6. Set the website bindings as shown below:
![Site Bindings](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/SiteBindings.png)

### Final Configuration
1. Copy the **C:\Python27\Lib\site-packages\wfastcgi.py** to the root directory of your new site. In my case it is the _C:\inetpub\hg_ directory.
2. Place the following script in the root directory and name it **hgweb.py**:
```conf
config = "hgweb.config"
from mercurial import demandimport; demandimport.enable()
from mercurial.hgweb import hgweb
application = hgweb(config)
```
3. Create a **hgweb.config** file and place it in the root directory. If you use the script below, please make sure you have a path to your repositories set. You can use the instructions available in Mercurial to reconfigure it later. Here is an example:
```conf
[web]
encoding = UTF-8
allow_push = *
push_ssl = False
allow_archive = gz zip bz2
descend = True
collapse = True
style=gitweb
[paths]
/ = C:\repos\*
```
**NOTE:** This method of listing repositories can be very slow if there are a number of repositories. It is better to list them individually.
4. Go to the IIS Admin **Sites** and select your Mercurial site. Go to **Handler Mappings**.
5. Click **Add Module Mapping** and provide the following details:
* **Request Path:** *
* **Module:** FastCgiModule
* **Executable:** C:\Python27\python.exe\|C:\inetpub\hg\wfastcgi.py
**WARNING:** There can not be any spaces between the values and the pipe (|) character otherwise it won't work and you will be hating life trying to figure out why its not working.      
* **Name:** hg-wfastcgi
Continue to the next step below.
6. Click on _Request Restrictions_ button.
* **Mapping** » Uncheck checkbox **Invoke handler only if request mapped to**.
* **Verbs:** » _All Verbs_ radio button selected.
* **Access:** » _Script_  radio button selected.
Click OK.
![Handler Mapping](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/HandlerMapping.png)
7. Click OK. This will prompt you to create an application to handle the requests. **Important** Click *Yes**.
![Create Application Handler](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/CreateApplicationHandler.png)
8. Configuring _wfastcgi_ to respond to Mercurial requests. Go to the IIS Admin _FastCGI Settings_ page.
![FastCGI Settings Default](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/FastCGISettings01.png)
9. You should see the newly created handler at the bottom of the list. Click **Edit** which will bring up the form window. If it doesn't exist, then you will need to **Add Application**. Fill in the following:
* **Full Path:** _C:\Python27\python.exe_ (Only required if adding application)
* **Arguments:** _C:\inetpub\hg\wfastcgi.py_ (Only required if adding application)
* **General » Max Instances:** 10
* **Process Model » Activity Timeout:** 300
* **Process Model » Idle Timeout:** 600
* **Process Model » Request Timeout:** 600
* **General » Environment Variables:** You will be adding the following environment variables:
* **Name:** _PYTHONPATH_ **Value:** _C:\inetpub\hg_
* **Name:** _WSGI_HANDLER_ **Value:** _hgweb.application_  
![FastCGI Settings Updated](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/FastCGISettings02.png)
![PYTHONPATH Environment Setting](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/PYTHONPATH.png)
![WSGI_HANDLER Environment Setting](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/WSGI_HANDLER.png)
10. Restart the web server and you should be in business. Open a browser and go to the address of the machine and you should see any repositories that are listed in your **hgweb.config** file.
![Mercurial on IIS](https://storage.googleapis.com/methodical-kaleidoscope-7367/2018/06/Success.png)

### Security
The application is not configured with authentication at this point. If you decide to use AD, you will need to configure IIS for the site to use AD. If you choose to use authentication, don't forget to modify the **hgweb.config** file to _allow_push_ for the users that should be allowed to push changes to the repository.

### References
* [Setting up a Mercurial server under IIS7 on Windows Server 2008 R2](http://nick.txtcc.com/index.php/other/910)
* [Running Mercurial 2.x Web server on IIS 7.5](http://blog.vishalon.net/running-mercurial-2-x-web-server-on-iis-7-5)
* [Setting up a Mercurial server under IIS7 on Windows Server 2008 R2](http://www.jeremyskinner.co.uk/mercurial-on-iis7/)
* [wfastcgi 3.0.0](https://pypi.org/project/wfastcgi/)
* [Deploying Python web app (Flask) in Windows Server (IIS) using FastCGI](https://medium.com/@bilalbayasut/deploying-python-web-app-flask-in-windows-server-iis-using-fastcgi-6c1873ae0ad8)
* [3.2. Getting the hgweb script](https://www.mercurial-scm.org/wiki/PublishingRepositories#hgweb)
* [Python Flask on IIS with wfastcgi](https://gist.github.com/bparaj/ac8dd5c35a15a7633a268e668f4d2c94)