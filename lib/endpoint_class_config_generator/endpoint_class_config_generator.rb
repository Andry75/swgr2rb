# frozen_string_literal: true

require 'json'
require 'active_support'
require 'active_support/core_ext'
require_relative '../json_fetcher/swagger_json_fetcher'
require_relative 'json_schema_definitions_parser_methods'
require_relative 'endpoint_class_config'
require_relative 'json_paths_parser_methods'

module Swgr2rb
  # EndpointClassConfigGenerator parses Swagger JSON, extracts
  # all parameters necessary for endpoint models generation,
  # and generates an array of EndpointClassConfig instances.
  class EndpointClassConfigGenerator
    include JsonSchemaDefinitionsParserMethods
    include JsonPathsParserMethods

    def initialize(swagger_path)
      @json = fetch_swagger_json(swagger_path)
      @schema_definitions = {}
    end

    def generate_configs
      generate_response_schema_definitions
      configs = @json[:paths].map do |request_path, request_hash|
        request_hash.map do |request_type, request_properties|
          generate_endpoint_config(request_path,
                                   request_type,
                                   request_properties)
        end
      end.flatten
      generate_uniq_identifiers(configs)
      configs
    end

    private

    def fetch_swagger_json(swagger_endpoint_path)
      JSON.parse(SwaggerJsonFetcher.get_swagger_json(swagger_endpoint_path)
                                   .to_json,
                 symbolize_names: true)
    end

    def generate_endpoint_config(request_path, request_type, request_properties)
      EndpointClassConfig.new(request_path.to_s,
                              generate_request_type(request_type,
                                                    request_properties),
                              generate_expected_response(request_properties),
                              generate_request_params(request_properties),
                              generate_operation_id(request_properties),
                              generate_version)
    end

    def generate_uniq_identifiers(configs)
      configs.group_by(&:operation_id)
             .select { |_operation_id, config_arr| config_arr.size > 1 }
             .each do |operation_id, config_arr|
        puts "Name conflict for operationId '#{operation_id}'. "\
             'Changing operationId for:'\
             "#{config_arr.map { |c| "\n\t#{c.endpoint_path}" }.join}"
        common_prefix = common_prefix(config_arr.map(&:endpoint_path))
        config_arr.each { |config| update_operation_id(config, common_prefix) }
      end
    end

    def update_operation_id(config, common_prefix)
      uniq_suffix = config.endpoint_path.dup.delete_prefix(common_prefix)
                          .gsub(/[{}]/, '').split('/').select(&:present?)
                          .map { |substr| substr[0].upcase + substr[1..] }.join
      config.operation_id = config.operation_id + uniq_suffix
    end

    def common_prefix(strings)
      if strings.size < 2
        strings.first
      else
        common_prefix(strings.each_slice(2).map do |str1, str2|
          str2.nil? ? str1 : common_prefix_for_two_strings(str1, str2)
        end)
      end
    end

    def common_prefix_for_two_strings(str1, str2)
      arr1 = str1.split('/')
      arr2 = str2.split('/')
      differ_at = (1...arr1.size).to_a.find { |i| arr1[i] != arr2[i] }
      arr1[0...differ_at].join('/')
    end
  end
end
