require 'rspec'
require 'swgr2rb'
require 'fileutils'

RSpec.describe Swgr2rb::EndpointClassesGenerator, :endpoint_classes_generator do
  context 'when generating endpoint classes' do
    it 'calls generators with correct parameters when { update_only: false, rewrite_schemas: false }' do
      endpoint_config = generate_endpoint_config(operation_id: 'GetRequest')
      stub_config_generator([endpoint_config])
      schema_generator_class = stub_schema_module_generator
      endpoint_generator_class = stub_endpoint_class_generator

      params = { target_dir: 'spec',
                 component: 'meow',
                 update_only: false,
                 rewrite_schemas: false }

      Swgr2rb::EndpointClassesGenerator.new('', params)
          .generate_endpoint_classes

      expect(schema_generator_class)
        .to have_received(:new)
        .with(endpoint_config,
              { target_dir: 'spec/meow/object_model_schemas',
                name: 'GetRequestSchema',
                update_only: false,
                rewrite: false })
      expect(endpoint_generator_class)
        .to have_received(:new)
        .with(endpoint_config,
              { target_dir: 'spec/meow',
                name: 'GetRequest',
                update_only: false,
                rewrite: false,
                modules_to_include: [
                  base_endpoint_object_model_methods,
                  {
                    name: 'GetRequestSchema',
                    path: 'object_model_schemas/get_request_schema'
                  }
                ],
                parent_class: base_endpoint_object_model })
    end
  end

  it 'calls generators with correct parameters when { update_only: true, rewrite_schemas: false }' do
    endpoint_config = generate_endpoint_config(operation_id: 'GetRequest_AllUsers')
    stub_config_generator([endpoint_config,
                           generate_endpoint_config(operation_id: 'PostRequest'),
                           generate_endpoint_config(operation_id: 'PutRequest')])
    schema_generator_class = stub_schema_module_generator
    endpoint_generator_class = stub_endpoint_class_generator

    params = { target_dir: 'spec',
               component: 'meow',
               update_only: true,
               rewrite_schemas: false }

    Swgr2rb::EndpointClassesGenerator.new('', params)
        .generate_endpoint_classes

    expect(schema_generator_class)
      .to have_received(:new)
      .with(endpoint_config,
            { target_dir: 'spec/meow/object_model_schemas',
              name: 'GetRequestAllUsersSchema',
              update_only: true,
              rewrite: false })
    expect(endpoint_generator_class)
      .to have_received(:new)
      .with(endpoint_config,
            { target_dir: 'spec/meow',
              name: 'GetRequestAllUsers',
              update_only: true,
              rewrite: false,
              modules_to_include: [
                base_endpoint_object_model_methods,
                {
                  name: 'GetRequestAllUsersSchema',
                  path: 'object_model_schemas/get_request_all_users_schema'
                }
              ],
              parent_class: base_endpoint_object_model })
  end

  it 'calls generators with correct parameters when { update_only: false, rewrite_schemas: true }' do
    endpoint_config = generate_endpoint_config(operation_id: 'Post_ABCRequest')
    stub_config_generator([endpoint_config])
    schema_generator_class = stub_schema_module_generator
    endpoint_generator_class = stub_endpoint_class_generator

    params = { target_dir: 'spec/target',
               component: 'meow',
               update_only: false,
               rewrite_schemas: true }

    Swgr2rb::EndpointClassesGenerator.new('', params)
        .generate_endpoint_classes

    expect(schema_generator_class)
      .to have_received(:new)
      .with(endpoint_config,
            { target_dir: 'spec/target/meow/object_model_schemas',
              name: 'PostAbcRequestSchema',
              update_only: false,
              rewrite: true })
    expect(endpoint_generator_class)
      .to have_received(:new)
      .with(endpoint_config,
            { target_dir: 'spec/target/meow',
              name: 'PostAbcRequest',
              update_only: false,
              rewrite: false,
              modules_to_include: [
                base_endpoint_object_model_methods,
                {
                  name: 'PostAbcRequestSchema',
                  path: 'object_model_schemas/post_abc_request_schema'
                }
              ],
              parent_class: base_endpoint_object_model })
  end

  it 'calls generators with correct parameters when { update_only: true, rewrite_schemas: true }' do
    endpoint_config = generate_endpoint_config(operation_id: 'Post_Create_User')
    stub_config_generator([endpoint_config])
    schema_generator_class = stub_schema_module_generator
    endpoint_generator_class = stub_endpoint_class_generator

    params = { target_dir: 'spec/target',
               component: 'meow',
               update_only: true,
               rewrite_schemas: true }

    Swgr2rb::EndpointClassesGenerator.new('', params)
        .generate_endpoint_classes

    expect(schema_generator_class)
      .to have_received(:new)
      .with(endpoint_config,
            { target_dir: 'spec/target/meow/object_model_schemas',
              name: 'PostCreateUserSchema',
              update_only: true,
              rewrite: true })
    expect(endpoint_generator_class)
      .to have_received(:new)
      .with(endpoint_config,
            { target_dir: 'spec/target/meow',
              name: 'PostCreateUser',
              update_only: true,
              rewrite: false,
              modules_to_include: [
                base_endpoint_object_model_methods,
                {
                  name: 'PostCreateUserSchema',
                  path: 'object_model_schemas/post_create_user_schema'
                }
              ],
              parent_class: base_endpoint_object_model })
  end
end
