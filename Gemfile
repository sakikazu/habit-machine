# TODO: rails6に上げるタイミングで、下記整理する
source 'https://rubygems.org'

ruby '2.7.1'
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
gem 'rest-client'

gem 'dotenv-rails'

# todo deleteしたいがform_withより楽だなぁ
gem 'simple_form'
gem 'font-awesome-rails'
gem 'lazy_high_charts'
gem 'browser'
gem 'redcarpet' # markdown
gem 'inline_svg'
gem 'enum_help'
gem 'seed-fu', '~> 2.3'

gem 'faker'

gem 'bootstrap', '>= 4.2', '< 5.0' # twitter bootstrap4
# todo 削除したいが、UIが結構良いので、できるだけ使い続ける
# TODO: moment.jsも含め、JSファイルサイズが大きいので、TimePickerだけができるライブラリに置き換えたい
# https://github.com/Bialogs/bootstrap4-datetime-picker-rails
gem 'bootstrap4-datetime-picker-rails'

gem 'uglifier', '>= 1.3.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 5.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# unicorn関連？
gem 'foreman'

# 定数管理
gem 'config'

# NOTE: View handlerの設定で使用されるのでどの環境でも必要
gem 'slim'

gem 'webpacker', '~> 5.x'

group :development do
  gem 'listen'
  gem 'slim-rails'                # generator時にslim対応可能になる
  gem 'view_source_map'           # webページ中に使用されているviewファイル名が見れる
  gem 'annotate'
  gem 'bullet'                    # n+1検出
  gem 'rubocop', require: false
  gem 'rack-mini-profiler', require: false        # 処理時間を表示
  gem 'letter_opener_web', '~> 2.0'

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
  gem 'factory_bot_rails'

  # テスト環境のテーブルをきれいにする
  gem 'database_rewinder'

  # デバッグ情報をフッターに出してくれる
  # memo rails5には対応していないようでコメントアウト
  # gem 'rails-footnotes'

  gem 'rails-erd'
end
