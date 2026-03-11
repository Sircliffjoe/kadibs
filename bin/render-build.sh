#!/usr/bin/env bash
# exit on error
set -o errexit

echo "=== Installing dependencies ==="
bundle install
yarn install --frozen-lockfile

echo "=== Building assets ==="
yarn build
yarn build:css

echo "=== Precompiling assets ==="
bundle exec rails assets:precompile

# Database migrations are run as part of the start command or release command


echo "=== Build complete ==="
