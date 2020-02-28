# frozen_string_literal: true

require_relative '../request_sender/conductor_sender'
require_relative '../request_sender/request'

module Swgr2rb
  # SwaggerJsonFetcher fetches a Swagger JSON given its path.
  # Since the path can either be a URL of Swagger or a path
  # to a .json file, SwaggerJsonFetcher either makes a GET request
  # to the given URL and returns its response, or reads and parses
  # a specified .json file.
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
        JSON.parse(File.read(file_path))
      rescue IOError, JSON::ParserError
        raise Swgr2rbError,
              "An error occurred while trying to read JSON file '#{file_path}'"
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
