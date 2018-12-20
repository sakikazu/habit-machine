source 'https://rubygems.org'

ruby '2.5.1'
gem 'rails', '~> 5.2.0'
gem 'bootsnap' # railsの起動を速くする

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
gem 'acts-as-taggable-on', '~> 6.0'

gem 'dotenv-rails'

gem 'simple_form'
gem 'best_in_place', '~> 3.0.1'
gem 'lazy_high_charts'

gem 'faker'

gem 'mini_racer'
gem 'bootstrap', '~> 4.1.3' # twitter bootstrap4

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 5.0'
  gem 'coffee-rails', '~> 4.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.3.0'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# unicorn関連？
gem 'foreman'

# 定数管理
gem 'config'

group :development do
  gem 'listen'

  # erbからhamlに変換
  gem 'erb2haml'

  # Use Capistrano for deployment
  gem 'capistrano', '3.2.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'rvm1-capistrano3', require: false

  # エラー画面をわかりやすく整形してくれる
  gem 'better_errors'

  # better_errorsの画面上にirb/pry(PERL)を表示する
  gem 'binding_of_caller'

end


group :development, :test do
  # Rails application preloader
  gem 'spring'

  # Railsコンソールの多機能版
  gem 'pry-rails'

  # pryの入力に色付け
  gem 'pry-coolline'

  # デバッガー
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
  gem "factory_bot"

  # テスト環境のテーブルをきれいにする
  gem 'database_rewinder'

  # デバッグ情報をフッターに出してくれる
  # memo rails5には対応していないようでコメントアウト
  # gem 'rails-footnotes'

  gem 'rails-erd'
end


