require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HabitMachine
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.default_locale = :ja
    config.time_zone = "Asia/Tokyo"

    config.generators do |g|
      g.view_specs false
      g.request_specs false
      g.controller_specs false
      g.helper false
      g.stylesheets false
      g.javascripts false
    end

    # エラーページにlayoutを適用させたいため
    # see. https://qiita.com/mr-myself/items/c2f4fb2e5dcee6a336f3#comment-23298b703d75b7d27487
    # NOTE: 本番環境のみ。開発環境は config.consider_all_requests_local = true なので、エラー時はデバッグ情報の画面になる
    config.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
