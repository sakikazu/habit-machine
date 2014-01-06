source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'devise'
gem "rails3_acts_as_paranoid"
gem 'exception_notification', :require => 'exception_notifier'
gem "sanitize"
gem 'paperclip'
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
gem 'acts-as-taggable-on'
gem 'jpmobile'

gem 'simple_form'
gem 'best_in_place'

gem 'rails_admin'
gem 'faker'

gem 'therubyracer', '0.10.2', :platforms => :ruby
gem "less-rails", '2.2.3' #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails", '2.1.3'
# gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
# gem 'execjs'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  # 2014/01/07、mongrel有効にすると「fastthread」関連でエラーが出る。ruby2のせい？
  # gem 'mongrel'
  # gem 'thin'

  # gem 'ruby-debug19'
  gem 'rails-erd'
  gem 'rails-footnotes'
  gem 'pry-rails'
end

group :development, :test do
  gem "rspec"
  gem "rspec-rails"
  # gem "factory_girl_rails" // 2012-08-25現在、r g scaffoldにてエラーになる
  gem "rails3-generators"
  gem "rr"
  gem "capybara"
  gem 'spork'
  gem "guard-spork"
  gem "guard-rspec"

  # gem "hocus_pocus"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
