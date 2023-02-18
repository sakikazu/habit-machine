require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HabitMachine
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.default_locale = :ja
    config.time_zone = 'Asia/Tokyo'

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
    config.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }
  end
end
