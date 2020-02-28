# frozen_string_literal: true

require_relative '../endpoint_class_config_generator/endpoint_class_config_generator'
require_relative 'endpoint_class_generator'
require_relative 'schema_module_generator'

module Swgr2rb
  # EndpointClassesGenerator calls a component that generates an array
  # of configs for endpoint models from Swagger JSON, and then invokes
  # Ruby file generators for each config.
  class EndpointClassesGenerator
    def initialize(swagger_endpoint_path, params)
      @swagger_endpoint_path = swagger_endpoint_path
      @params = params
    end

    def generate_endpoint_classes
      EndpointClassConfigGenerator.new(@swagger_endpoint_path)
                                  .generate_configs.map do |endpoint_config|
        endpoint_class_name = generate_class_name(endpoint_config.operation_id)
        SchemaModuleGenerator.new(endpoint_config,
                                  generate_schema_opts(endpoint_class_name))
                             .generate_file

        EndpointClassGenerator.new(endpoint_config,
                                   generate_class_opts(endpoint_class_name))
                              .generate_file
      end
    end

    private

    def generate_class_name(operation_id)
      operation_id.gsub('_', '').split(/([[:upper:]][[:lower:]]+)/)
                  .select(&:present?).map(&:capitalize).join
    end

    def generate_schema_opts(endpoint_class_name)
      {
        target_dir: File.join(@params[:target_dir],
                              @params[:component],
                              'object_model_schemas'),
        name: "#{endpoint_class_name}Schema",
        update_only: @params[:update_only],
        rewrite: @params[:rewrite_schemas]
      }
    end

    def generate_class_opts(class_name)
      {
        target_dir: File.join(@params[:target_dir], @params[:component]),
        name: class_name,
        modules_to_include: [base_config('BaseEndpointObjectModelMethods'),
                             generate_config_for_schema(class_name)].compact,
        parent_class: base_config('BaseEndpointObjectModel'),
        update_only: @params[:update_only],
        rewrite: false
      }
    end

    def generate_config_for_schema(class_name)
      {
        name: "#{class_name}Schema",
        path: File.join('object_model_schemas',
                        RubyFileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call("#{class_name}Schema"))
      }
    end

    def base_config(name)
      {
        name: name,
        path: File.join('..', RubyFileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call(name))
      }
    end
  end
end
