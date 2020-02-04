require 'httparty'
require_relative 'response'

module Swgr2rb
  class ConductorSender
    class << self
      def send_request(request)
        response = send("send_#{request.type}_request",
                        request)

        Response.new(response)
      end

      private

      def send_get_request(request)
        HTTParty.get(request.url, query: request.body, headers: request.headers, verify: false)
      end
    end
  end
end
