source "https://rubygems.org"

gem "rails", "~> 8.1.2"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false

gem "kamal", require: false

gem "thruster", require: false

gem "image_processing", "~> 1.2"

# =============================================================================
# Kadibs CMMS Core Dependencies
# =============================================================================

gem "devise", "~> 4.9"
gem "pundit", "~> 2.4"
gem "paper_trail", "~> 17.0"
gem "aasm", "~> 5.5"
gem "friendly_id", "~> 5.5"
gem "discard", "~> 1.3"
gem "rqrcode", "~> 2.2"
gem "caxlsx", "~> 4.1"
gem "caxlsx_rails", "~> 0.6"
gem "prawn", "~> 2.5"
gem "prawn-table", "~> 0.2"
gem "pagy", "~> 9.3"
gem "blueprinter", "~> 1.1"
gem "jwt", "~> 2.8"
gem "pg_search", "~> 2.3"
gem "chartkick", "~> 5.1"
gem "groupdate", "~> 6.5"
gem "phonelib", "~> 0.9"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "shoulda-matchers", "~> 6.0"
end

group :development do
  gem "web-console"
end
