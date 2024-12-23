## John Yeary Blog

This blog is a port of Ghost's default theme [Casper](https://github.com/tryghost/casper) for Jekyll inspired by [Kasper](https://github.com/rosario/kasper).

[![Build Status](https://api.travis-ci.com/jyeary/jyeary.github.io.svg?branch=3.0.0)](https://travis-ci.com/jyeary/jyeary.github.io)
[![Ruby](https://img.shields.io/badge/ruby-3.3.4-blue.svg?style=flat)](https://travis-ci.org/jyeary/jyeary.github.io)
[![Jekyll](https://img.shields.io/badge/jekyll-3.1.0-blue.svg?style=flat)](https://travis-ci.org/jyeary/jyeary.github.io)


## How to use it

### Deployment

**Important:**  For security reasons, Github does not allow plugins (under _plugins/) when deploying with Github Pages. This means:

**1)** that we need to generate your site locally (more details below) and push the resulting HTML to a Github repository;

**2)** built the site with [travis-ci](https://travis-ci.com/) (with goodies from [jekyll-travis](https://github.com/mfenner/jekyll-travis)) automatically pushing the generated *_site/* files to your *gh-pages* branch.
 This later approach is the one I am currently using to generate the live site.

For option **1)** simply clone this repository (*master branch*), and then run `bundle exec jekyll serve` inside the directory. Upload the resulting *_site/* contents to your repository (*master branch* if uploading as your personal page (username.github.io) or *gh-pages branch* if uploading as a project page (as for the [demo](https://github.com/jekyller/jasper/tree/gh-pages)).

For option **2)** you will need to set up travis-ci for your personal fork. Briefly all you need then is to change your details in *[\_config.yml](_config.yml)* so that you can push to your github repo.

Set the following parameters in the Travis CI repo settings environment variables:
* **GIT_USER** - This is your Github username
* **GIT_EMAIL** - This is a valid Github email address assigned to this account.
* **GH_TOKEN** - This is a Github personal authentication token.

Alternatively, you can also need to generate a secure key to add to your *[.travis.yml](.travis.yml)* (you can find more info on how to do it in that file). 

Make sure you read the documentation from [jekyll-travis](https://github.com/mfenner/jekyll-travis). This approach has clear advantages in that you simply push changes to your files and all the html files are generated for you. Also you get to know if everything is still fine with your site builds. Don't hesitate to contact me if you still have any issues (see below about issue tracking).

### Docker

You can pull the source from the repository using any branch, but the default (master) and then do the following to build and test it before deploying.

```shell
docker container run -it --rm -p 4000:4000 -v $PWD:/blog ruby:3.3.4 /bin/bash
```

The simplest way to run the application is:
```shell
cd /blog && \
gem install bundler -v 2.6.1 && \
bundle install && \
bundle exec jekyll serve
```

or you may need some form like below for specific versions:
```shell
cd /blog && \
gem install bundler -v 2.6.1 && \
gem install sass-embedded -v 1.83 && \
gem install jekyll && \
bundle install && \
bundle exec jekyll serve
```

### Updating Ruby Gems

Modify the `Gemfile` with the appropriate changes and run the following.

```
bundle update
```

Compare the generated `Gemfile.lock` and make sure that the changes meet the requirements from [Github Pages Dependency versions](https://pages.github.com/versions/).

### Author pages

In order to properly generate author pages you need to rename the field *categories* in the front matter of every post to match that of your each author *username* as defined in the *[\_config.yml](_config.yml)* file.
With the latest update, multiple author blogs are now supported out of the box.


## Copyright & License

Same licence as the one provided by Ghost's team. See Casper's theme [license](GHOST.txt).

Copyright (C) 2009-2024 John Yeary

Copyright (C) 2015-2021 - Released under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
