Rails.application.config.assets.version = "1.0"

Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets')
Rails.application.config.assets.precompile += %w( jquery.js ckeditor/*)
