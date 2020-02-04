require_relative '../endpoint_class_config_generator/endpoint_class_config_generator'
require_relative 'endpoint_class_generator'
require_relative 'schema_module_generator'

module Swgr2rb
  class EndpointClassesGenerator
    def initialize(swagger_endpoint_path, params)
      @swagger_endpoint_path = swagger_endpoint_path
      @params = params
    end

    def generate_endpoint_classes
      EndpointClassConfigGenerator.new(@swagger_endpoint_path).generate_configs.map do |endpoint_class_config|
        endpoint_class_name = generate_class_name(endpoint_class_config.operation_id)
        SchemaModuleGenerator.new(endpoint_class_config,
                                  generate_schema_module_opts(endpoint_class_name))
            .generate_file

        EndpointClassGenerator.new(endpoint_class_config,
                                   generate_endpoint_class_opts(endpoint_class_name))
            .generate_file
      end
    end

    private

    def generate_class_name(operation_id)
      operation_id.sub('_', '').split(/([[:upper:]][[:lower:]]+)/).select(&:present?).map(&:capitalize).join
    end

    def generate_schema_module_opts(endpoint_class_name)
      {
          target_dir: File.join(@params[:target_dir], @params[:component], 'object_model_schemas'),
          name: "#{endpoint_class_name}Schema",
          update_only: @params[:update_only],
          rewrite: @params[:rewrite_schemas]
      }
    end

    def generate_endpoint_class_opts(endpoint_class_name)
      {
          target_dir: File.join(@params[:target_dir], @params[:component]),
          name: endpoint_class_name,
          modules_to_include: [config_for_base_methods,
                               generate_config_hash_for_schema(endpoint_class_name),
                               generate_config_hash_for_validator(endpoint_class_name)].compact,
          parent_class: config_for_base_class,
          update_only: @params[:update_only],
          rewrite: @params[:rewrite_classes]
      }
    end

    def config_for_base_methods
      @base_methods_config ||= generate_config_hash_for_base_class('BaseEndpointObjectModelMethods')
    end

    def config_for_base_class
      @base_class_config ||= generate_config_hash_for_base_class('BaseEndpointObjectModel')
    end

    def generate_config_hash_for_schema(class_name)
      {
          name: "#{class_name}Schema",
          path: File.join('object_model_schemas',
                          FileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call("#{class_name}Schema") + '.rb')
      }
    end

    def generate_config_hash_for_validator(class_name)
      module_name = "#{class_name}Validator"
      module_path = File.join('object_model_validators',
                              FileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call(module_name) + '.rb')
      if File.exist?(File.join(@params[:target_dir], module_path))
        { name: module_name, path: module_path }
      end
    end

    def generate_config_hash_for_base_class(name)
      {
          name: name,
          path: File.join('..', FileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call(name))
      }
    end
  end
end
