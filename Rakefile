#############################################################################
#
# Local development tasks for this Jekyll site.
#
# Build and deployment to GitHub Pages is now handled by GitHub Actions
# (see .github/workflows/jekyll.yml) — the old Travis/CircleCI-based
# deploy task that pushed to a separate destination branch has been
# removed, since Actions builds and deploys directly from this branch.
#
#############################################################################

require 'rake'

namespace :site do
  desc "Generate the site"
  task :build do
    sh "bundle exec jekyll build"
  end

  desc "Generate the site and serve locally"
  task :serve do
    sh "bundle exec jekyll serve"
  end

  desc "Generate the site, serve locally and watch for changes"
  task :watch do
    sh "bundle exec jekyll serve --watch"
  end
end