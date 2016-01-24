require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rails4
  class Application < Rails::Application

    config.middleware.use 'Sample::Middleware'
    # Rack::Sendfile is the first middleware in the production env
    config.middleware.insert_before Rack::Sendfile, StackProf::Middleware, enabled: false,
                       mode: :cpu,
                       interval: 1000,
                       save_every: 100
  end
end
