Rails.application.config.assets.version = "1.0"

Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets')
Rails.application.config.assets.precompile += %w( jquery.js )


#precompile
Rails.application.config.assets.precompile += %w( modal_handler.js modal_handler.css )
