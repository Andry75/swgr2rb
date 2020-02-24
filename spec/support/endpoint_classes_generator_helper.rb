require_relative 'endpoint_class_config_helper'

module EndpointClassesGeneratorHelper
  include EndpointClassConfigHelper

  def stub_config_generator(configs)
    config_generator = double('config_generator', generate_configs: configs)
    allow(Swgr2rb::EndpointClassConfigGenerator).to receive(:new).and_return(config_generator)
  end

  def stub_schema_module_generator
    schema_generator = double('schema_generator', generate_file: nil)
    schema_generator_class = class_spy(Swgr2rb::SchemaModuleGenerator)
                             .as_stubbed_const(transfer_nested_constants: true)
    allow(schema_generator_class).to receive(:new).and_return(schema_generator)
    schema_generator_class
  end

  def stub_endpoint_class_generator
    endpoint_generator = double('endpoint_generator', generate_file: nil)
    endpoint_generator_class = class_spy(Swgr2rb::EndpointClassGenerator)
                               .as_stubbed_const(transfer_nested_constants: true)
    allow(endpoint_generator_class).to receive(:new).and_return(endpoint_generator)
    endpoint_generator_class
  end

  def base_endpoint_object_model_methods
    {
      name: 'BaseEndpointObjectModelMethods',
      path: '../base_endpoint_object_model_methods'
    }
  end

  def base_endpoint_object_model
    {
      name: 'BaseEndpointObjectModel',
      path: '../base_endpoint_object_model'
    }
  end
end
