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
# TODO: best_in_placeはクセが強い(application.js参照)ので、いずれJSで置き換える
gem 'best_in_place'
gem 'font-awesome-rails'
gem 'lazy_high_charts'
gem 'browser'
gem 'redcarpet' # markdown

gem 'faker'

gem 'mini_racer'
gem 'bootstrap', '~> 4.1.3' # twitter bootstrap4

gem 'uglifier', '>= 1.3.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 5.0'
  gem 'coffee-rails', '~> 4.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
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

# NOTE: View handlerの設定で使用されるのでどの環境でも必要
gem 'slim'

group :development do
  gem 'rb-readline'
  gem 'listen'
  gem 'slim-rails'                # generator時にslim対応可能になる
  gem 'view_source_map'           # webページ中に使用されているviewファイル名が見れる
  gem 'annotate'
  gem 'bullet'                    # n+1検出
  gem 'rubocop', require: false
  gem 'rack-mini-profiler'        # 処理時間を表示

  # Use Capistrano for deployment
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'rvm1-capistrano3', require: false

  # エラー画面をわかりやすく整形してくれる
  gem 'better_errors'

  # better_errorsの画面上にirb/pry(PERL)を表示する
  gem 'binding_of_caller'
end

group :development, :test do
  # Rails application preloader
  gem 'spring'

  # rails consoleでpryを使うために必要
  gem 'pry-rails'

  # デバッガー
  gem 'pry-byebug'

  # Pryでの便利コマンド
  gem 'pry-doc'

  # PryでのSQLの結果を綺麗に表示。Hirb.enableの実行が必要
  gem 'hirb'

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

