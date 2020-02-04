require_relative '../request_sender/conductor_sender'
require_relative '../request_sender/request'

module Swgr2rb
  class SwaggerJsonFetcher
    class << self
      def get_swagger_json(endpoint_path)
        request = generate_request_to_swagger(endpoint_path)
        response = ConductorSender.send_request(request)
        response.body
      end

      private

      def generate_request_to_swagger(endpoint_path)
        Request.new(endpoint_path,
                    'get',
                    nil,
                    nil)
      end
    end
  end
end
