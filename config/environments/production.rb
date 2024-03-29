Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # E-mail settings
  config.action_mailer.delivery_method = :sendmail

  config.action_mailer.perform_deliveries = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  if Rails.application.secrets['graylog']['enabled'] == true
    graylog_settings = Rails.application.secrets['graylog']
    graylog_host = graylog_settings['host'] || '127.0.0.1'
    graylog_port = graylog_settings['port'] || 12201
    graylog_network_locality = graylog_settings['network_locality'] || :WAN
    graylog_protocol = graylog_settings['protocol'] || 'udp'
    graylog_protocol = graylog_protocol.downcase == 'tcp' ? GELF::Protocol::TCP : GELF::Protocol::UDP
    graylog_facility = graylog_settings['facility']
    graylog_verbosity = graylog_settings['verbosity'] || 'info'

    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Graylog2.new
    config.logger = GELF::Logger.new(graylog_host, graylog_port,
        graylog_network_locality, { :protocol => graylog_protocol,
                                    :facility => graylog_facility })
    config.log_level = graylog_verbosity
    config.colorize_logging = false
    # Log controller params, too
    config.lograge.custom_options = lambda do |event|
      params = event.payload[:params].reject { |k| %w(controller action).include?(k) }
      { "params" => params }
    end
  else
    # Create a standard logger that writes to log/production.log and rotates them.
    # This ages the logfile once it reaches a certain size. Leave 12 “old” log files where 
    # each file is about 10485760 bytes.
    config.logger = Logger.new(Rails.root.join('log', "#{Rails.env}.log"), 12, 10485760)
    config.log_level = :warn
  end
end
