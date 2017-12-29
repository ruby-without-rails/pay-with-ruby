require 'sentry-raven'

module PayWithRuby
  module Utils
    # Module to handle Log of messages with Sentry
    # @docs https://docs.sentry.io/hosted/clients/ruby/
    module Logger
      class << self
        # Log a message with 'error' level
        def error(context, options = nil)
          options = options.merge(level: 'error')
          log(context, options)
        end

        # Log a message with 'info' level
        def info(context, options = nil)
          options = options.merge(level: 'info')
          log(context, options)
        end

        # Log a message with 'warning' level
        def warning(context, options = nil)
          options = options.merge(level: 'warning')
          log(context, options)
        end

        # Log a message with Sentry
        #
        # @param [String, StandardError] context
        # @param [Hash] options Extra data to send to Sentry.
        # @option options [String] :level
        # @option options [Hash] :tags
        # @option options [Hash] :extra
        # @option options [Hash] :user
        # @return nil
        def log(context, options = nil)
          if context.is_a? String
            Raven.capture_message(context, options)
          else
            Raven.capture_exception(context, options)
          end
        end

        # Set user information to the next log requests
        #
        # @param [Hash] options
        # @return nil
        def set_user_context(options)
          Raven.user_context(options)
        end
      end
    end
  end
end
