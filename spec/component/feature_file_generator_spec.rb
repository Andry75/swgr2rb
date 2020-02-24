require 'rspec'
require 'swgr2rb'
require 'fileutils'

RSpec.describe Swgr2rb::FeatureFileGenerator do
  let(:target_dir) { 'spec/target_dir' }
  after(:each) { FileUtils.rm_r(target_dir) }

  it 'generates an example feature file' do
    component = 'amazing_component'

    # create endpoint object model file
    object_models_dir = 'harness/endpoint_object_models/object_models'
    object_model_dir = File.join(target_dir,
                                 object_models_dir,
                                 component)
    FileUtils.mkdir_p(object_model_dir)
    File.open(File.join(object_model_dir, 'get_all_users.rb'), 'w') do |file|
      file.write("class GetAllUsers\nend")
    end

    # create directory for an example feature file
    feature_file_dir = File.join(target_dir,
                                 'harness/features/component',
                                 component)
    FileUtils.mkdir_p(feature_file_dir)

    Dir.chdir(target_dir) do
      Swgr2rb::FeatureFileGenerator
        .new(target_dir: object_models_dir,
             component: component)
        .generate_feature_file
    end

    ff_filename = File.join(feature_file_dir, 'ff001_example.feature')
    expect(File.exist?(ff_filename))
      .to be(true)
    expect(File.read(ff_filename).lines(chomp: true).select(&:present?))
      .to eq(['@component_amazing_component',
              '@ff001',
              'Feature: Example of JSON schema validation feature file',
              '  @ff001_tc01',
              '  Scenario: Send get request to Get All Users endpoint',
              '    When I send "get" request to "Get All Users"',
              '    Then the response schema for "get" request to "Get All Users" endpoint should be valid'])
  end
end
