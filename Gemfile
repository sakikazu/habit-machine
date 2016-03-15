source 'https://rubygems.org'

gem 'rails', '4.1.14'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'devise'
gem "paranoia", "~> 2.0"
gem 'exception_notification'
gem "sanitize"
gem 'paperclip'
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
gem 'acts-as-taggable-on', '~> 3.4'
# gem 'jpmobile'

gem 'dotenv-rails'

gem 'simple_form'
gem 'best_in_place', '~> 3.0.1'
gem 'lazy_high_charts'

gem 'faker'

gem 'therubyracer', platforms: :ruby
gem 'less-rails'
gem "twitter-bootstrap-rails"
# gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
# gem 'execjs'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.3.0'
end

# memo jquery 1.9以上になるとliveが使えずエラーになるのでバージョン指定
gem 'jquery-rails', '2.1.3'
gem 'jquery-ui-rails', '2.0.2'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# unicorn関連？
gem 'foreman'

# 定数管理
gem 'rails_config'

group :development do
  # erbからhamlに変換
  gem 'erb2haml'

  # Use Capistrano for deployment
  gem 'capistrano', '3.2.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'rvm1-capistrano3', require: false
end


group :development, :test do
  # Rails application preloader
  gem 'spring'

  # Railsコンソールの多機能版
  gem 'pry-rails'

  # pryの入力に色付け
  gem 'pry-coolline'

  # デバッカー
  gem 'pry-byebug'

  # Pryでの便利コマンド
  gem 'pry-doc'

  # PryでのSQLの結果を綺麗に表示
  gem 'hirb'
  gem 'hirb-unicode'

  # pryの色付けをしてくれる
  gem 'awesome_print'

  # Rspec
  gem 'rspec-rails'

  # fixtureの代わり
  gem "factory_girl_rails"

  # テスト環境のテーブルをきれいにする
  gem 'database_rewinder'

  # デバッグ情報をフッターに出してくれる
  gem 'rails-footnotes', '>= 4.0.0', '<5'

  gem 'rails-erd'
end


