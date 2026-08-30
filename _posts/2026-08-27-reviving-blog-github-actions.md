---
layout: post
cover: 'assets/images/pexels-su-lopes-54155462-10564614.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2026-08-27 09:00:00+00:00
title: "Reviving This Blog: Ditching Travis CI for GitHub Actions"
categories: jyeary
tags: jekyll docker github-actions ruby ai-assisted
subclass: 'post tag-jekyll tag-docker tag-github-actions tag-ruby tag-ai-assisted'
---

Life got in the way of this blog for a while, and the longer I stayed away, the harder it got to come back. By the time I wanted to write again, I'd forgotten the exact incantation to build the site locally, and the CI pipeline that published it — Travis CI — had quietly become impractical to keep using. Every part of getting back to writing had a mountain to climb first. This post is a summary of what it took to clear those mountains out of the way, with an assist from Claude along the way.

### The state of things

The site is a Jekyll blog with a couple of custom plugins (a tag page generator and an author generator), which meant it could never use GitHub's native "just push and Pages builds it" option — custom plugins aren't allowed there. So it always needed its own CI system to build the site and publish the result. That used to be Travis CI, pushing the built `_site/` output to a deploy branch. Travis's free tier for this kind of use is essentially gone now, so that pipeline had stopped being viable.

### Getting local builds working again in Docker

First things first: I wanted to be able to build and preview the site locally without installing Ruby directly on my machine. The `Gemfile` already pinned a specific Ruby version to match what GitHub Pages supports, so I wrapped that in a small Docker-based script that mounts the repo, installs gems, and runs `jekyll serve` — matching the same Ruby version the CI would eventually use, so "works on my machine" would actually mean something.

```sh
docker run -it --rm \
  -p 4000:4000 \
  -v "$PWD":/blog \
  -w /blog \
  ruby:3.3.4 \
  /bin/bash -c "gem install bundler && bundle install && bundle exec jekyll serve --host 0.0.0.0"
```

### Replacing Travis with GitHub Actions

Since custom plugins rule out GitHub's native Pages build, the replacement needed to build the site itself and publish the result. I put together a GitHub Actions workflow that installs the pinned Ruby version, runs `bundle exec jekyll build`, and hands the output to GitHub's official Pages deployment action. No more personal access tokens, no more pushing built output to a separate branch by hand — Actions builds it and deploys it in the same run.

Switching this on also meant changing the Pages source in the repo settings from "Deploy from a branch" to "GitHub Actions," which is easy to miss — the workflow can run and succeed while Pages keeps quietly serving whatever the old branch-based deploy last pushed, until that setting is flipped.

### A CSS regression, and a lesson about baseurl

The first real deploy looked fine on the homepage but broke on every nested page, like tag listings — no styling at all. The theme links its stylesheet with `{{ site.baseurl }}assets/css/screen.css`, relying entirely on `site.baseurl` to supply the leading slash. My first pass at the workflow had it building with an explicit `--baseurl` flag pulled from GitHub's Pages metadata, which resolved to an empty string for this custom-domain setup. That silently turned the stylesheet link into a relative path, which happened to still work from the homepage but broke as soon as the page was one directory deeper. Dropping that flag and letting `_config.yml`'s own `baseurl: /` do the job, exactly like the old Travis build did, fixed it.

### Cleaning out what Travis left behind

With Actions handling everything, `.travis.yml` and the `.circleci/` directory could go, along with the Travis-flavored integration on GitHub itself. The `Rakefile` also had a `deploy` task built entirely around pushing to a separate destination branch — dead weight now that Actions builds and deploys directly from source. I trimmed it down to just the local `build`/`serve`/`watch` tasks. That in turn left several keys in `_config.yml` — `username`, `repo`, `branch`, `destination`, and a couple of others — with nothing left to reference them, so those came out too.

### Keeping dependencies current without breaking things

The last piece was making sure this doesn't rot again. I added a Dependabot config for the Bundler and GitHub Actions ecosystems, set to open pull requests on a weekly schedule rather than push changes directly. Since the Actions workflow builds on every push, each dependency-bump PR gets build-tested automatically before I ever have to decide whether to merge it.

None of this changes a single word of any post here — it's all plumbing. But plumbing that's easy to run locally and boring to maintain is exactly what lets me actually get back to writing instead of fighting the blog itself.