# Datadog APM Configuration for ddtrace 1.23.3
# Simplified but stable configuration

require 'ddtrace'
require 'ddtrace/auto_instrument'

# Configure Datadog APM
Datadog.configure do |c|
  app_name = 'pilot'
  # === Core Configuration ===
  c.service = ENV.fetch('DD_SERVICE') { app_name }
  c.env = ENV.fetch('DD_ENV') { Rails.env }
  c.version = ENV.fetch('DD_VERSION') { '0.1.0' }

  # === Agent Configuration ===
  c.agent.host = ENV.fetch('DD_AGENT_HOST') { 'dd-agent' }
  c.agent.port = ENV.fetch('DD_TRACE_AGENT_PORT') { 8126 }.to_i

  # === Tracing Configuration ===
  c.tracing.enabled = true
  c.tracing.analytics.enabled = true

  # === Sampling Configuration ===
  c.tracing.sampling.default_rate = ENV.fetch('DD_TRACE_SAMPLE_RATE') { '1.0' }.to_f
  c.tracing.sampling.rate_limit = ENV.fetch('DD_TRACE_RATE_LIMIT') { '100' }.to_i

  # === Profiling Configuration ===
  c.profiling.enabled = ENV.fetch('DD_PROFILING_ENABLED') { 'true' } == 'true'

  # === Runtime Metrics ===
  c.runtime_metrics.enabled = true

  # === Instrumentation Configuration ===

  # Rails instrumentation
  c.tracing.instrument :rails, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-api",
    distributed_tracing: true,
    analytics_enabled: true,
    analytics_sample_rate: 1.0,
    request_queuing: false,
    middleware: true,
    middleware_names: true
  }

  c.tracing.instrument :rack, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-rack",
    analytics_enabled: true,
    analytics_sample_rate: 1.0,
    distributed_tracing: true,
    middleware_names: true
  }

  # PostgreSQL instrumentation
  c.tracing.instrument :pg, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-postgres",
    analytics_enabled: true,
    analytics_sample_rate: 1.0
  }

  # Redis instrumentation
  c.tracing.instrument :redis, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-redis",
    analytics_enabled: false,
    analytics_sample_rate: 0.0,
    on_error: proc do |span, error|
      span.set_tag('error', true)
      span.set_tag('error.message', error.message)
    end
  }

  # ActionCable instrumentation
  c.tracing.instrument :action_cable, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-websocket",
    analytics_enabled: true
  }

  # HTTP client instrumentation
  c.tracing.instrument :http, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-http",
    analytics_enabled: true,
    distributed_tracing: true
  }

  # Sidekiq instrumentation (if using background jobs)
  c.tracing.instrument :sidekiq, {
    service_name: "#{ENV.fetch('DD_SERVICE') { app_name }}-sidekiq",
    analytics_enabled: true,
    analytics_sample_rate: 1.0
  }

  # === Environment-Specific Configuration ===
  case Rails.env
  when 'development'
    # More verbose logging in development
    c.diagnostics.debug = true
    c.logger.level = ::Logger::DEBUG

  when 'test'
    # Disable tracing in test environment for better performance
    c.tracing.enabled = false
    c.profiling.enabled = false
    c.runtime_metrics.enabled = false

  when 'production'
    # Production optimizations
    c.diagnostics.debug = false
    c.logger.level = ::Logger::WARN

    # Enable error tracking
    c.tracing.report_hostname = true

    # Production sampling rates (adjust as needed)
    c.tracing.sampling.default_rate = ENV.fetch('DD_TRACE_SAMPLE_RATE') { '0.1' }.to_f
  end

  # === Custom Tags ===
  c.tags = {
    'team' => 'engineering',
    'component' => 'api',
    'ruby_version' => RUBY_VERSION,
    'rails_version' => Rails.version
  }
end

# === Additional Configuration ===


# Configure DogStatsD for custom metrics
require 'datadog/statsd'

# Initialize StatsD client
$statsd = Datadog::Statsd.new(
  ENV.fetch('DD_AGENT_HOST') { 'dd-agent' },
  ENV.fetch('DD_DOGSTATSD_PORT') { 8125 }.to_i,
  namespace: ENV.fetch('DD_SERVICE') { 'pilot' },
  tags: [
    "env:#{ENV.fetch('DD_ENV') { Rails.env }}",
    "service:#{ENV.fetch('DD_SERVICE') { 'pilot' }}",
    "version:#{ENV.fetch('DD_VERSION') { '0.1.0' }}"
  ]
)

# Log configuration status
Rails.logger.info "[DATADOG] APM initialized with service: #{ENV.fetch('DD_SERVICE') { 'pilot' }}, env: #{ENV.fetch('DD_ENV') { Rails.env }}"
