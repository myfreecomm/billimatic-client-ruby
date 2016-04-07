require "billimatic/exception"

module Billimatic
  RequestTimeout = Class.new(Exception)
  RequestError = Class.new(Exception)

  class Response < SimpleDelegator
    def resolve!(&block)
      if success? #TODO: test redirect if need
        block_given? ? yield(self) : self
      elsif timed_out?
        timeout!
      else
        error!
      end
    end

    private
      def timeout!
        raise RequestTimeout
      end

      def error!
        raise RequestError.new(
          code: code,
          message: status_message,
          body: (MultiJson.load(body) rescue {})
        )
      end

  end
end
