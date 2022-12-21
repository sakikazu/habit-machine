# TODO: 最新のRailsでは、 force_ssl: true のみで実現できるため、このファイルは削除できるっぽい
if Rails.application.config.force_ssl
  Rails.application.routes.default_url_options[:protocol] = 'https'
end
