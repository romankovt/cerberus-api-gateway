# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("PUMA_MAX_THREADS", 2)
min_threads_count = ENV.fetch("PUMA_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 4567.
port ENV.fetch("PORT", 4567)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("APP_ENV", "development")

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# config option may reduce latency and improve throughput for high-load Puma apps on MRI
# it waits for less busy worker while request is queued to be dispatched
wait_for_less_busy_worker 0.001

lowlevel_error_handler do |_e|
  [
    500,
    {},
    [
      <<-ERROR_MESSAGE.squish << "\n"
        An error has occurred, and engineers have been informed. Please reload the page. If you continue to have
        problems, please contact support.
      ERROR_MESSAGE
    ]
  ]
end
