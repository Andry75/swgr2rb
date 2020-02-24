require 'rspec'
require 'swgr2rb'
require_relative '../support/swagger_json_builder'
require_relative '../support/swagger_json_path_builder'
require 'pry'

RSpec.describe Swgr2rb::EndpointClassConfigGenerator, :endpoint_class_config_generator do
  let(:config_generator) { Swgr2rb::EndpointClassConfigGenerator.new('') }
  context 'generate_configs' do
    it 'generate with correct data' do
      definitions = {
        FirstModel: { name: String, number: Integer },
        SecondModel: { name: String, address: String }
      }
      stub_swagger_json(build_default_json(definitions, {}))

      config_generator.generate_configs
      generated_definitions = config_generator.instance_variable_get('@schema_definitions')

      expect(generated_definitions).to eq(definitions)
    end

    it 'generate with correct data and path' do
      definitions = {
        FirstModel: { name: String, number: Integer },
        SecondModel: { name: String, address: String }
      }

      path = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(200, [Integer])
                                            .json]
      }
      stub_swagger_json(build_default_json(definitions, path))

      configs = config_generator.generate_configs
      generated_definitions = config_generator.instance_variable_get('@schema_definitions')

      expect(generated_definitions).to eq(definitions)
      expect(configs.first.expected_response.code).to eq(200)
    end

    it 'generate with correct data, path and not uniq id' do
      first_path = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(200, [Integer])
                                            .json]
      }

      id_first_path = first_path[:"api/first"].first["get"][:"operationId"]
      second_path = {
        'api/second': [SwaggerJsonPathBuilder.new('get')
                                             .set_operation_id(id_first_path)
                                             .build_response(201, String)
                                             .json]
      }

      stub_swagger_json(build_default_json({}, first_path.merge(second_path)))
      configs_not_uniq = config_generator.generate_configs

      expect(configs_not_uniq.first.operation_id).not_to eq(configs_not_uniq.second.operation_id)
      expect(configs_not_uniq.first.operation_id).to eq(id_first_path + "First")
      expect(configs_not_uniq.second.operation_id).to eq(id_first_path + "Second")
      expect(configs_not_uniq.first.expected_response.code).to eq(200)
      expect(configs_not_uniq.second.expected_response.code).to eq(201)
    end
  end
end
