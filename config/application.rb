require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdvancePromoCodeShopifyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.action_dispatch.default_headers.delete('X-Frame-Options')
    config.load_defaults 6.0

    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_job.queue_adapter = :delayed_job
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{yml}')]

      # Load application's lib classes
    config.to_prepare do
      Dir.glob(File.join(File.dirname(__FILE__), "../lib/**/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
