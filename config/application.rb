require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CollegeKeyFoundationApi
  class Application < Rails::Application
    config.action_cable.mount_path = '/websocket'
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(6.0) && (config.autoloader = :classic)
    config.api_only = true
    config.assets.enabled = false
    config.autoload_paths << Rails.root.join('lib')

    config.active_job.queue_adapter = :async

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      if File.exist?(env_file)
        YAML.safe_load(File.open(env_file)).each do |key, value|
          ENV[key.to_s] = value
        end
      end
    end

    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins 'college-key-foundation.herokuapp.com', 'localhost:3000', '127.0.0.1:3000', 'collegekeyfoundation.org', 'www.collegekeyfoundation.org'
        resource '*', headers: :any, methods: %i[get post delete put patch options head]
      end
    end
    
    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies # Required for all session management
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options

  end
end
