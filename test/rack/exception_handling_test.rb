require_relative '../test_helper'

class ExceptionHandlingTest < MiniTest::Unit::TestCase
  class FakeLogger
    def write(*args)
      @written = args
    end

    def flush(*args)
      @printed = @written
    end

    def printed
      @printed
    end
  end

  def test_reports_errors_as_json
    app = ->(env) { fail "Test Error" }

    middleware = Chassis::Rack::ExceptionHandling.new(app)

    env = { 'rack.errors' => FakeLogger.new }

    status, headers, body = middleware.call(env)

    assert_equal 'application/json', headers.fetch('Content-Type')
    refute_empty body
    hash = JSON.load body.each.to_a.join('')

    assert_equal 500, status
  end

  def test_prints_trace_to_error_stream
    app = ->(env) { fail "Test Error" }

    middleware = Chassis::Rack::ExceptionHandling.new(app)

    logger = FakeLogger.new
    env = { 'rack.errors' => logger }

    middleware.call(env)

    refute_empty logger.printed
  end
end
