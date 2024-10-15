require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SocialApp
  class Application < Rails::Application
    # Set API-only mode
    config.api_only = true

    # Remove static file middleware
    config.middleware.delete ActionDispatch::Static

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Use the lowest log level to ensure availability of diagnostic information
    # when problems arise.
    config.log_level = :debug

    # Prepend all log lines with the following tags.
    config.log_tags = [:request_id]

    Rails.application.configure do
      config.hosts.clear
    end

    # config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
