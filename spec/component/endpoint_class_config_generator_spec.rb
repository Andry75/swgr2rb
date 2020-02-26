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
          status: Swgr2rb::Boolean,
          randomObject: Hash
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

  context 'when generating endpoint_path and request_type' do
    it 'works correctly for path with one request type' do
      paths = {
        'api/first' => [SwaggerJsonPathBuilder.new('get').build_response(200, String).json],
        'api/second' => [SwaggerJsonPathBuilder.new('post').build_response(201, nil).json]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.map { |config| { config.endpoint_path => config.request_type } }
                    .reduce(&:merge))
        .to eq({ 'api/first' => :get,
                 'api/second' => :post })
    end

    it 'works correctly for path with several request types' do
      paths = {
        'api/first' => [
          SwaggerJsonPathBuilder.new('get').build_response(200, String).json,
          SwaggerJsonPathBuilder.new('post').build_response(201, nil).json
        ],
        'api/second' => [
          SwaggerJsonPathBuilder.new('get').build_response(200, Integer).json,
          SwaggerJsonPathBuilder.new('put').build_response(204, nil).json,
          SwaggerJsonPathBuilder.new('delete').build_response(200, nil).json
        ]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.map { |config| [config.endpoint_path, config.request_type] })
        .to eq([['api/first', :get],
                ['api/first', :post],
                ['api/second', :get],
                ['api/second', :put],
                ['api/second', :delete]])
    end
  end

  context 'when generating request_params' do
    it 'works correctly for path params' do
      paths = {
        'api/users/{userId}' => [
          SwaggerJsonPathBuilder.new('get')
                                .build_parameter('userId', :path, Integer)
                                .build_response(200, String)
                                .json
        ],
        'api/records/{recordId}/{status}' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('recordId', :path, Integer)
                                .build_parameter('status', :path, Swgr2rb::Boolean)
                                .build_response(200, nil)
                                .json
        ]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_params.to_h)
        .to eq({ path: [{ name: 'userId', schema: Integer }],
                 query: [], form_data: [], body: [] })
      expect(configs.last.request_params.to_h)
        .to eq({ path: [{ name: 'recordId', schema: Integer },
                        { name: 'status', schema: Swgr2rb::Boolean }],
                 query: [], form_data: [], body: [] })
    end

    it 'works correctly for query params' do
      paths = {
        'api/records' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('recordId', :query, Integer)
                                .build_parameter('status', :query, Swgr2rb::Boolean)
                                .build_response(200, nil)
                                .json
        ]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_params.to_h)
        .to eq({ query: [{ name: 'recordId', schema: Integer },
                         { name: 'status', schema: Swgr2rb::Boolean }],
                 path: [], form_data: [], body: [] })
    end

    it 'works correctly for body param which is a single value' do
      paths = {
        'api/users/{userId}' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('userId', :path, Integer)
                                .build_parameter('status', :body, Swgr2rb::Boolean)
                                .build_response(200, nil)
                                .json
        ]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_params.to_h)
        .to eq({ path: [{ name: 'userId', schema: Integer }],
                 body: [{ name: 'status', schema: Swgr2rb::Boolean }],
                 query: [], form_data: [] })
    end

    it 'works correctly for body param which is an array of values' do
      paths = {
        'api/records/touch' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('recordIds', :body, [Integer])
                                .build_response(200, nil)
                                .json
        ]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_params.to_h)
        .to eq({ body: [{ name: 'recordIds', schema: [Integer] }],
                 path: [], query: [], form_data: [] })
    end

    it 'works correctly for body param which references schema definition' do
      definitions = {
        UserModel: { email: String, isAdmin: Swgr2rb::Boolean },
        UsersModel: { items: [:UserModel], total: Integer }
      }
      paths = {
        'api/users' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('UserModel', :body, :UserModel)
                                .build_response(201, nil)
                                .json
        ],
        'api/users/bulk' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('UsersModel', :body, :UsersModel)
                                .build_response(201, nil)
                                .json
        ]
      }
      stub_swagger_json(build_default_json(definitions, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_params.to_h)
        .to eq({ body: [{ name: 'UserModel',
                          schema: { email: String, isAdmin: Swgr2rb::Boolean } }],
                 path: [], query: [], form_data: [] })
      expect(configs.last.request_params.to_h)
        .to eq({ body: [{ name: 'UsersModel',
                          schema: { items: [{ email: String, isAdmin: Swgr2rb::Boolean }],
                                    total: Integer } }],
                 path: [], query: [], form_data: [] })
    end

    it 'does not add optional params to the config' do
      paths = {
        'api/users/{userId}' => [
          SwaggerJsonPathBuilder.new('post')
                                .build_parameter('userId', :path, Integer, optional: true)
                                .build_parameter('status', :query, Swgr2rb::Boolean, optional: true)
                                .build_parameter('strings', :body, [String], optional: true)
                                .build_parameter('file', :formData, :file, optional: true)
                                .build_response(200, nil)
                                .json
        ]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_params.to_h)
        .to eq({ path: [], query: [], form_data: [], body: [] })
    end
  end

  context 'when working with multipart requests' do
    it 'generates request_type and request_params correctly' do
      paths = {
        'api/first' => [SwaggerJsonPathBuilder.new('post')
                                              .build_parameter('file', :formData, :file)
                                              .build_response(201, nil)
                                              .json]
      }
      stub_swagger_json(build_default_json({}, paths))

      configs = config_generator.generate_configs

      expect(configs.first.request_type)
        .to eq(:multipart_post)
      expect(configs.first.request_params.to_h)
        .to eq({ form_data: [{ name: 'file', schema: File }],
                 path: [], query: [], body: [] })
    end
  end

  it 'generates operation_id and version correctly' do
    paths = {
      'api/users/{userId}' => [
        SwaggerJsonPathBuilder.new('get')
                              .build_parameter('userId', :path, Integer)
                              .build_response(200, String)
                              .set_operation_id('GetRequest_OperationId')
                              .json
      ]
    }
    stub_swagger_json(SwaggerJsonBuilder.new
                          .build_paths(paths)
                          .set_version('2.0')
                          .json)

    configs = config_generator.generate_configs

    expect(configs.first.operation_id)
      .to eq('GetRequest_OperationId')
    expect(configs.first.version)
      .to eq(2)
  end

  context 'when generate_configs is called' do
    it 'generates with correct data' do
      definitions = {
          FirstModel: { name: String, number: Integer },
          SecondModel: { name: String, address: String }
      }
      stub_swagger_json(build_default_json(definitions, {}))

      config_generator.generate_configs
      generated_definitions = config_generator.instance_variable_get('@schema_definitions')

      expect(generated_definitions).to eq(definitions)
    end

    it 'generates with correct data and path' do
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

    it 'generates with correct data, path and not uniq id' do
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
