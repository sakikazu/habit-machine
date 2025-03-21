source 'https://rubygems.org'

ruby '3.2.6'
gem 'rails', '~> 6.1'
gem 'bootsnap', require: false # railsの起動を速くする

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'devise'
gem "paranoia", "~> 2.0"
gem 'exception_notification'
gem "sanitize"
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
gem 'acts-as-taggable-on'
gem 'rest-client'
gem 'dotenv-rails'
# used by ActiveStorage
gem "image_processing", ">= 1.2"
# todo deleteしたいがform_withより楽だなぁ
gem 'simple_form'
gem 'font-awesome-rails'
gem 'lazy_high_charts'
gem 'browser'
gem 'redcarpet' # markdown
gem 'inline_svg'
gem 'enum_help'
gem 'seed-fu', '~> 2.3'

# この2つはcapistrano実行時のssh関連エラーの対応のため
gem 'ed25519'
gem 'bcrypt_pbkdf'

gem 'faker'

gem 'bootstrap', '~> 4.6', '>= 4.6.2.1' # twitter bootstrap4
# 多分bootstrapに必要
gem 'sassc-rails'

# todo 削除したいが、UIが結構良いので、できるだけ使い続ける
# TODO: moment.jsも含め、JSファイルサイズが大きいので、TimePickerだけができるライブラリに置き換えたい
# https://github.com/Bialogs/bootstrap4-datetime-picker-rails
gem 'bootstrap4-datetime-picker-rails'

gem 'uglifier', '>= 1.3.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
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

gem 'puma'

# 起動時の `uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger (NameError)` 対策
gem 'concurrent-ruby', '1.3.4'

# unicorn関連？
gem 'foreman'

# 定数管理
gem 'config'

# NOTE: View handlerの設定で使用されるのでどの環境でも必要
gem 'slim'
# for scss; NOTE: 2.4にすると、VPSでbundle installが終わらなくなる
gem 'sassc', '2.1.0'

gem 'webpacker', '~> 5.x'

# enexのスクリプトに使用
gem 'tty-prompt'

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
  gem 'capistrano-asdf'
  gem 'capistrano3-puma'

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
  # gem 'pry-doc'

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
