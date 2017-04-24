# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/1_Redroid_intro.webm"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/2_Redroid_configuration.webm"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/3_Redroid_streaming_video.webm"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/4_Redroid_rules.webm"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/5_Redroid_motion detection.webm"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/6_Redroid_location_logging.webm"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos/7_Redroid_bike_cam.webm"
