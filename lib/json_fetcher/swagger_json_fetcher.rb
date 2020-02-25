require_relative '../request_sender/conductor_sender'
require_relative '../request_sender/request'

module Swgr2rb
  class SwaggerJsonFetcher
    class << self
      def get_swagger_json(path)
        if URI.extract(path).present?
          send_request_to_swagger(path)
        else
          read_file(path)
        end
      end

      private

      def send_request_to_swagger(endpoint_path)
        request = generate_request_to_swagger(endpoint_path)
        response = ConductorSender.send_request(request)
        response.body
      end

      def read_file(file_path)
        begin
          JSON.parse(File.read(file_path))
        rescue IOError, JSON::ParserError
          raise Swgr2rbError, "An error occurred while trying to read JSON file '#{file_path}'"
        end
      end

      def generate_request_to_swagger(endpoint_path)
        Request.new(endpoint_path,
                    'get',
                    nil,
                    nil)
      end
    end
  end
end
