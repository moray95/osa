# frozen_string_literal: true
module OSA
  class HttpClient
    def initialize(connection)
      @connection = connection
    end

    def get(*args, **kwargs)
      response = @connection.get(*args, **kwargs)
      handle_response(response)
    end

    def post(*args, **kwargs)
      response = @connection.post(*args, **kwargs)
      handle_response(response)
    end

    def delete(*args, **kwargs)
      response = @connection.delete(*args, **kwargs)
      handle_response(response)
    end

    def patch(*args, **kwargs)
      response = @connection.patch(*args, **kwargs)
      handle_response(response)
    end

    private

      def handle_response(response)
        if response.status > 299
          raise StandardError, "Request failed with status code: #{response.status}, body: #{response.body}"
        end
        if response.headers['content-type'].include?('application/json')
          JSON.parse(response.body)
        else
          response.body
        end
      end
  end
end
