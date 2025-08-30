# Добавляем явные логи для тестирования Datadog
Rails.logger.info "[STARTUP] Rails application started with Datadog logging - #{Time.current}"

# Инициализатор для тестирования логов
Rails.application.configure do
  config.after_initialize do
    Rails.logger.info '[DATADOG] Application initialized successfully'
    Rails.logger.info "[DATADOG] Trace correlation: #{Datadog::Tracing.correlation.inspect}" if defined?(Datadog::Tracing)
  end
end

# Middleware для генерації Rails логів з Datadog кореляцією
class DatadogRequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    # Обов'язково виводимо лог (не залежно від інших налаштувань)
    puts "🚀 [MIDDLEWARE] Processing #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"

    request = ActionDispatch::Request.new(env)
    start_time = Time.current

    # Лог початку запиту з trace correlation
    correlation = Datadog::Tracing.correlation
    trace_info = correlation.trace_id && correlation.trace_id != 0 ?
      " (trace_id: #{correlation.trace_id})" : ''

    Rails.logger.info "Started #{request.method} \"#{request.fullpath}\" for #{request.remote_ip} at #{start_time}#{trace_info}"
    puts "📍 [RAILS] Started #{request.method} \"#{request.fullpath}\" for #{request.remote_ip} at #{start_time}#{trace_info}"

    status, headers, response = @app.call(env)
    duration = (Time.current - start_time) * 1000

    # Лог завершення запиту з trace correlation
    correlation = Datadog::Tracing.correlation # Оновлюємо correlation
    trace_info = correlation.trace_id && correlation.trace_id != 0 ?
      " (trace_id: #{correlation.trace_id})" : ''

    Rails.logger.info "Completed #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} in #{duration.round(1)}ms#{trace_info}"
    puts "✅ [RAILS] Completed #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} in #{duration.round(1)}ms#{trace_info}"

    [ status, headers, response ]
  rescue => e
    correlation = Datadog::Tracing.correlation
    trace_info = correlation.trace_id && correlation.trace_id != 0 ?
      " (trace_id: #{correlation.trace_id})" : ''

    Rails.logger.error "Request failed: #{e.class.name} (#{e.message})#{trace_info}"
    puts "❌ [RAILS] Request failed: #{e.class.name} (#{e.message})#{trace_info}"
    raise
  end
end

# Додаємо middleware на початок стеку
Rails.application.config.middleware.insert_before 0, DatadogRequestLogger
