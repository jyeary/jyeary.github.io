#!/bin/bash
# Build & preview the Jekyll blog locally using Docker.
# Matches the Ruby version pinned in the Gemfile (3.3.4) and the
# GitHub Actions workflow, so "works on my machine" == "works in CI".
#
# Usage:
#   ./serve-local.sh
# Then open http://localhost:4000 in your browser.
# Edits to _posts/, _layouts/, etc. auto-rebuild (jekyll serve watches by default).
# Ctrl+C to stop.

set -euo pipefail

docker run -it --rm \
  -p 4000:4000 \
  -v "$PWD":/blog \
  -w /blog \
  ruby:3.3.4 \
  /bin/bash -c "
    gem install bundler -v 2.6.1 && \
    bundle install && \
    bundle exec jekyll serve --host 0.0.0.0
  "
