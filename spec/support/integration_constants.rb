# frozen_string_literal: true

require 'swgr2rb'

module IntegrationConstants
  ENDPOINT_MODEL_STUBS = {
    create_user: proc do |builder|
      builder.build_definitions(UserModel: JSON_MODELS[:user_model])
             .build_paths('api/users': [SwaggerJsonPathBuilder
                                         .new('post')
                                         .build_parameter('userModel', :body, :UserModel)
                                         .build_response(201, nil)
                                         .build_operation_id('CreateUser')
                                         .json])
    end,
    get_all_users: proc do |builder|
      builder.build_definitions(UserModel: JSON_MODELS[:user_model],
                                PaginatedUserModel: JSON_MODELS[:paginated_user_model])
             .build_paths('api/users': [SwaggerJsonPathBuilder
                                         .new('get')
                                         .build_response(200, :PaginatedUserModel)
                                         .build_operation_id('GetAllUsers')
                                         .json])
    end,
    upload_user_key: proc do |builder|
      builder.build_paths('api/users/{userId}/key': [SwaggerJsonPathBuilder
                                                       .new('post')
                                                       .build_parameter('userId', :path, Integer)
                                                       .build_parameter('key', :formData, :file)
                                                       .build_response(200, Swgr2rb::Boolean)
                                                       .build_operation_id('UploadUserKey')
                                                       .json])
    end,
    update_record: proc do |builder|
      path = 'api/v{version}/records/{recordId}'
      builder.build_version('1.0')
             .build_paths(path.to_sym => [SwaggerJsonPathBuilder
                                            .new('put')
                                            .build_parameter('version', :path, String)
                                            .build_parameter('recordId', :path, Integer)
                                            .build_parameter('status', :query, Swgr2rb::Boolean)
                                            .build_response(204, nil)
                                            .build_operation_id('UpdateRecord')
                                            .json])
    end,
    delete_record: proc do |builder|
      path = 'api/records/{parentRecordId}/{recordId}'
      builder.build_paths(path.to_sym => [SwaggerJsonPathBuilder
                                            .new('delete')
                                            .build_parameter('parentRecordId', :path, Integer)
                                            .build_parameter('recordId', :path, Integer)
                                            .build_response(200, nil)
                                            .build_operation_id('DeleteRecord')
                                            .json])
    end,
    get_all_records: proc do |builder|
      builder.build_definitions(CommentModel: JSON_MODELS[:comment_model],
                                RecordModel: JSON_MODELS[:record_model])
             .build_paths('api/records': [SwaggerJsonPathBuilder
                                            .new('get')
                                            .build_response(200, [:RecordModel])
                                            .build_operation_id('GetAllRecords')
                                            .json])
    end
  }.freeze

  JSON_MODELS = {
    user_model: {
      fullName: String,
      email: String,
      passwordHash: String,
      status: Swgr2rb::Boolean
    },
    paginated_user_model: {
      items: [:UserModel],
      total: Integer
    },
    record_model: {
      name: String,
      randomFloat: Float,
      randomObject: Hash,
      comments: [:CommentModel]
    },
    comment_model: {
      title: String,
      arrayOfInts: [Integer]
    }
  }.freeze

  EXPECTED_ENDPOINT_FILENAME = proc do |endpoint_name, component_name|
    "endpoint_object_models/object_models/#{component_name}/#{endpoint_name}.rb"
  end
  EXPECTED_SCHEMA_FILENAME = proc do |endpoint_name, component_name|
    "endpoint_object_models/object_models/#{component_name}/object_model_schemas/#{endpoint_name}_schema.rb"
  end
  GENERATED_DIRECTORIES = proc do |component_name|
    ["endpoint_object_models/object_models/#{component_name}",
     "endpoint_object_models/object_models/#{component_name}/object_model_schemas",
     'features/component',
     "features/component/#{component_name}"]
  end
  EXPECTED_FEATURE_FILENAME = proc do |component_name|
    "features/component/#{component_name}/ff001_example.feature"
  end
end.freeze
