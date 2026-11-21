#!/usr/bin/env bash
# exit on error
set -o errexit

bundle config unset deployment || true
bundle config set --local frozen false
bundle config set --local deployment false
bundle install
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails assets:precompile
bundle exec rails assets:clean
