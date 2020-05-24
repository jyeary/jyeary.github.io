---
layout: post
cover: 'assets/images/abstract-apple-art-black-and-white-434346.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: false
date: 2009-12-14 16:28:00+00:00
title: OS X Account Settings Panther and Leopard (10.3/10.4)
categories: jyeary
tags: mac
subclass: 'post tag-mac'
---
### OS X (10.3)  
Accounts will not appear in the account list unless UID values are above 500.  

### OS X (10.4)  
  
#### To hide an account:  

```
sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add account1
```  
This will hide the user names, but has the side effect of adding a login called **Other**. 
  
#### To prevent the Other login from appearing use:  

```
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool false
```

### Unhide Accounts 
To unhide all the names you may have previously hidden, you could execute the following from the command line.  

```
sudo defaults delete /Library/Preferences/com.apple.loginwindow HiddenUsersList
```
