## John Yeary Blog

This blog is a port of Ghost's default theme [Casper](https://github.com/tryghost/casper) for Jekyll inspired by [Kasper](https://github.com/rosario/kasper).

[![Build and deploy Jekyll site](https://github.com/jyeary/jyeary.github.io/actions/workflows/jekyll.yml/badge.svg?branch=3.0.0)](https://github.com/jyeary/jyeary.github.io/actions/workflows/jekyll.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.3.4-blue.svg?style=flat)](https://github.com/jyeary/jyeary.github.io/actions/workflows/jekyll.yml)
[![Jekyll](https://img.shields.io/badge/jekyll-4.4.1-blue.svg?style=flat)](https://github.com/jyeary/jyeary.github.io/actions/workflows/jekyll.yml)


## How to use it

### Deployment

The site is built and published by GitHub Actions. The workflow is defined in
*[.github/workflows/jekyll.yml](.github/workflows/jekyll.yml)*: every push to the
`3.0.0` branch (or a manual run from the **Actions** tab) builds the site with
`jekyll build` and deploys the generated *_site/* directory straight to GitHub
Pages via [`actions/deploy-pages`](https://github.com/actions/deploy-pages).

Because the build runs in the workflow rather than on GitHub's own Pages build,
custom plugins under *_plugins/* are supported.

To set this up on a fork:

1. Update your details in *[\_config.yml](_config.yml)*.
2. In the repository settings, under **Settings → Pages**, set **Source** to
   **GitHub Actions**.
3. Push to the `3.0.0` branch (or adjust the branch name in
   *[.github/workflows/jekyll.yml](.github/workflows/jekyll.yml)*).

No personal access tokens or extra secrets are required — the workflow uses the
built-in `GITHUB_TOKEN`.

### Building locally

Clone this repository and run `bundle exec jekyll serve` inside the directory to
preview the site at `http://localhost:4000`. The generated output lives in
*_site/*.

### Docker

If you don't have Ruby installed locally, build and preview the site from the
`ruby:3.3.4` image (matching the version pinned in the `Gemfile` and the
workflow):

```shell
docker container run -it --rm -p 4000:4000 -v $PWD:/blog -w /blog ruby:3.3.4 /bin/bash
```

Then, inside the container:

```shell
gem install bundler -v 2.6.1 && \
bundle install && \
bundle exec jekyll serve --host 0.0.0.0
```

The site is served at `http://localhost:4000`.

### Updating Ruby Gems

The site runs a current Jekyll (4.x) and is built/deployed entirely by GitHub
Actions, so there is no GitHub Pages dependency set to match. To update:

```shell
bundle update
```

Review the `Gemfile.lock` diff, then confirm the build still succeeds
(`bundle exec jekyll build`) before pushing — the workflow runs the same
command.

### Author pages

In order to properly generate author pages you need to rename the field *categories* in the front matter of every post to match that of your each author *username* as defined in the *[\_config.yml](_config.yml)* file.
With the latest update, multiple author blogs are now supported out of the box.


## Copyright & License

Same licence as the one provided by Ghost's team. See Casper's theme [license](GHOST.txt).

Copyright (C) 2009-2026 John Yeary

Copyright (C) 2015-2021 - Released under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
