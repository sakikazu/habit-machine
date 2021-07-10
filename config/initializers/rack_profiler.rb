# frozen_string_literal: true

if Rails.env.development?
  # とりあえず使わない
  # 他のプラグインgemを入れれば、メモリ使用量とかも見れる
  # require "rack-mini-profiler"

  # # initialization is skipped so trigger it
  # Rack::MiniProfilerRails.initialize!(Rails.application)
end
