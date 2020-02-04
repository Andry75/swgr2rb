require 'json'
require 'active_support'
require 'active_support/core_ext'
require_relative '../json_fetcher/swagger_json_fetcher'
require_relative 'json_schema_definitions_parser_methods'
require_relative 'endpoint_class_config'
require_relative 'json_paths_parser_methods'

module Swgr2rb
  class EndpointClassConfigGenerator
    include JsonSchemaDefinitionsParserMethods
    include JsonPathsParserMethods

    def initialize(swagger_endpoint_path)
      @json = fetch_swagger_json(swagger_endpoint_path)
      @schema_definitions = {}
    end

    def generate_configs
      generate_response_schema_definitions
      configs = @json[:paths].map do |request_path, request_hash|
        request_hash.map do |request_type, request_properties|
          EndpointClassConfig.new(request_path.to_s,
                                  generate_request_type(request_type, request_properties),
                                  generate_expected_response(request_properties),
                                  generate_request_params(request_properties),
                                  generate_operation_id(request_properties),
                                  generate_version)
        end
      end.flatten
      generate_uniq_identifiers(configs)
      configs
    end

    private

    def fetch_swagger_json(swagger_endpoint_path)
      JSON.parse(SwaggerJsonFetcher.get_swagger_json(swagger_endpoint_path).to_json,
                 symbolize_names: true)
    end

    def generate_uniq_identifiers(configs)
      configs.group_by(&:operation_id)
          .select { |_operation_id, config_arr| config_arr.size > 1 }
          .each do |operation_id, config_arr|
        common_prefix = common_prefix(config_arr.map(&:endpoint_path))
        config_arr.each do |config|
          uniq_suffix = config.endpoint_path.dup.delete_prefix(common_prefix)
                            .gsub(/[{}]/, '').split('/').select(&:present?)
                            .map { |substr| substr[0].upcase + substr[1..] }.join
          config.operation_id = operation_id + uniq_suffix
        end
      end
    end

    def common_prefix(strings)
      if strings.size < 2
        strings.first
      else
        common_prefix(strings.each_slice(2).map { |str1, str2| common_prefix_for_two_strings(str1, str2) })
      end
    end

    def common_prefix_for_two_strings(str1, str2)
      arr1, arr2 = str1.split('/'), str2.split('/')
      differ_at = (1...arr1.size).to_a.find { |i| arr1[i] != arr2[i] }
      arr1[0...differ_at].join('/')
    end
  end
end
