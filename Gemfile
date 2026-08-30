source "https://rubygems.org"

ruby "3.3.4"

# The site is built and deployed by GitHub Actions (see
# .github/workflows/jekyll.yml), not by GitHub's own Pages builder, so we
# run a current Jekyll instead of the version-locked `github-pages` gem.
gem "jekyll", "~> 4.3"
gem "rake", "~> 13.0"

# Removed from Ruby's default gems in 3.4; liquid still expects it.
gem "bigdecimal", "~> 3.1"

# The site has no Sass sources; pin the lighter 2.x converter so the build
# doesn't pull the large sass-embedded native gem.
gem "jekyll-sass-converter", "~> 2.2"

group :jekyll_plugins do
  gem "jekyll-sitemap", "~> 1.4"
  gem "jekyll-paginate", "~> 1.1"
end
