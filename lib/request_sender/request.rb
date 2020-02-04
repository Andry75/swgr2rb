module Swgr2rb
  class Request
    attr_reader :type, :headers, :body, :subdomain, :endpoint_name

    def initialize(endpoint_name, type, headers, body)
      @endpoint_name = endpoint_name
      @type = type
      @headers = headers
      @body = body
      process_request_type
    end

    def url
      generate_url
    end

    private

    def process_request_type
      if type.split(' ').length > 1
        @type = type.split(' ').join('_')
      end
    end

    def generate_url
      "https://#{endpoint_name}"
    end
  end
end
