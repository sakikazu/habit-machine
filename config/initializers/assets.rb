# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("node_modules")
# Rails 8ではTurbolinks Engineのasset pathが自動追加されないため明示する
turbolinks_source_path = Gem.loaded_specs.fetch("turbolinks-source").full_gem_path
Rails.application.config.assets.paths << File.join(turbolinks_source_path, "lib/assets/javascripts")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
  application.js
  categories.js
  day_page.js
  diaries_sidebar.js
  diary_show.js
  habitodos.js
  hello_vue.js
  search.js
  todo_page.js
]
