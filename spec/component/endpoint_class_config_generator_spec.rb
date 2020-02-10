require 'rspec'
require 'swgr2rb'
require_relative '../support/swagger_json_builder'
require_relative '../support/swagger_json_path_builder'

RSpec.describe Swgr2rb::EndpointClassConfigGenerator, :endpoint_class_config_generator do
  let(:config_generator) { Swgr2rb::EndpointClassConfigGenerator.new('') }

  context 'when parsing schema definitions' do
    it 'parses a schema with one key correctly' do
      definitions = { SingleStringModel: { name: String } }
      stub_swagger_json(build_default_json(definitions, {}))

      config_generator.generate_configs
      generated_definitions = config_generator.instance_variable_get('@schema_definitions')

      expect(generated_definitions).to eq(definitions)
    end

    it 'parses a schema with multiple keys correctly' do
      definitions = {
        ComplicatedModel: {
          name: String,
          id: Integer,
          description: String,
          probability: Float,
          status: Swgr2rb::Boolean
        }
      }
      stub_swagger_json(build_default_json(definitions, {}))

      config_generator.generate_configs
      generated_definitions = config_generator.instance_variable_get('@schema_definitions')

      expect(generated_definitions).to eq(definitions)
    end

    it 'parses a schema that references another schema correctly' do
      definitions = {
        UserModel: { name: String },
        AdminModel: { user: :UserModel, active: Swgr2rb::Boolean },
        PaginatedUsersModel: { users: [:UserModel], total: Integer }
      }
      stub_swagger_json(build_default_json(definitions, {}))

      config_generator.generate_configs
      generated_definitions = config_generator.instance_variable_get('@schema_definitions')

      expect(generated_definitions)
        .to include(UserModel: { name: String })
        .and include(AdminModel: { user: { name: String }, active: Swgr2rb::Boolean })
        .and include(PaginatedUsersModel: { users: [{ name: String }], total: Integer })
    end
  end

  context 'when generating expected_response' do
    it 'parses empty response correctly' do
      paths = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(200)
                                            .json]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.expected_response.code).to eq(200)
      expect(configs.first.expected_response.schema).to eq(nil)
    end

    it 'parses single value response correctly' do
      paths = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(201, String)
                                            .json]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.expected_response.code).to eq(201)
      expect(configs.first.expected_response.schema).to eq(String)
    end

    it 'parses response which is an array of values correctly' do
      paths = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(200, [Integer])
                                            .json]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.expected_response.code).to eq(200)
      expect(configs.first.expected_response.schema).to eq(Integer)
    end

    it 'parses response which references a schema definition correctly' do
      response_model = { SimpleModel: { name: String, status: Swgr2rb::Boolean } }
      paths = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(200, response_model.keys.first)
                                            .json]
      }
      stub_swagger_json(build_default_json(response_model, paths))

      configs = config_generator.generate_configs

      expect(configs.first.expected_response.code).to eq(200)
      expect(configs.first.expected_response.schema).to eq(response_model.values.first)
    end

    it 'parses response which is an array of items that reference a schema definition correctly' do
      response_model = { SimpleModel: { name: String, status: Swgr2rb::Boolean } }
      paths = {
        'api/first': [SwaggerJsonPathBuilder.new('get')
                                            .build_response(200, [response_model.keys.first])
                                            .json]
      }
      stub_swagger_json(build_default_json(response_model, paths))

      configs = config_generator.generate_configs

      expect(configs.first.expected_response.code).to eq(200)
      expect(configs.first.expected_response.schema).to eq(response_model.values.first)
    end
  end
end
