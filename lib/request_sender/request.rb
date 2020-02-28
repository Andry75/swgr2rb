# frozen_string_literal: true

module Swgr2rb
  # Request contains all parameters necessary for making an API request.
  # Its instances are being passed to ConductorSender.send_request.
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
      @type = type.split(' ').join('_') if type.split(' ').length > 1
    end

    def generate_url
      "https://#{endpoint_name}"
    end
  end
end
