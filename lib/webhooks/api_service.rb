module Webhooks
  class ApiService
    extend Dry::Initializer

    def get(endpoint:, path:, query: {})
      request(method: :get, endpoint: endpoint, path: path, query: query)
    end

    def post(endpoint:, path:, body: '', headers: {})
      request(method: :post, endpoint: endpoint, path: path, body: body, headers: headers)
    end

    def request(method:, endpoint:, path:, query: {}, body: '', headers: {})
      response(method: method, endpoint: endpoint, path: path, query: query, body: body, headers: headers)
    end

    def response(method:, endpoint:, path:, query: {}, body: '', headers: {})
      connection(endpoint).send(method, path) do |request|
        request.body = body
        request.params = query
        request.headers = headers
      end
    end

    def connection(endpoint)
      ::Faraday.new(url: endpoint) do |builder|
        builder.request :json
        builder.response :json
        builder.adapter :net_http
        builder.options[:open_timeout] = 30
        builder.options[:timeout] = 30
      end
    end
  end
end
