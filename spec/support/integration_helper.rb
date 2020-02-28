# frozen_string_literal: true

require 'swgr2rb'
require 'json'
require_relative 'integration_constants'
require_relative 'swagger_json_builder'

module IntegrationHelper
  include IntegrationConstants

  def create_swagger_json_file(endpoints, filename)
    json_builder = SwaggerJsonBuilder.new
    endpoints.each do |endpoint|
      IntegrationConstants::ENDPOINT_MODEL_STUBS[endpoint].call(json_builder)
    end
    json = json_builder.json.to_json
    File.open(filename, 'w') do |file|
      file.write(json)
    end
    json
  end

  def swgr2rb(args_string)
    Dir.chdir('tmp') do
      suppress_stdout do
        Swgr2rb::Main.new(args_string.split(' ')).execute
      end
    end
  end

  def expected_generated_filenames(component, endpoints)
    (all_filenames_recursive('assets') +
       IntegrationConstants::GENERATED_DIRECTORIES.call(component) +
       generated_endpoint_files(endpoints, component) +
       [IntegrationConstants::EXPECTED_FEATURE_FILENAME.call(component)]).sort
  end

  def actual_generated_filenames
    all_filenames_recursive('tmp/harness').sort
  end

  def all_filenames_recursive(directory_name)
    Dir.glob("#{directory_name}/**/*")
       .map { |filename| filename.sub(%r{^#{Regexp.escape(directory_name)}/}, '') }
  end

  def generated_endpoint_files(endpoints, component)
    endpoints.map do |endpoint|
      [IntegrationConstants::EXPECTED_ENDPOINT_FILENAME.call(endpoint, component),
       IntegrationConstants::EXPECTED_SCHEMA_FILENAME.call(endpoint, component)]
    end.reduce(:+)
  end

  def generated_endpoint_filepath(relative_path)
    File.join('tmp', 'harness', relative_path)
  end

  def expected_endpoint_filepath(relative_path)
    File.join('spec', 'samples', relative_path.split('/').last.sub('.rb', '.txt'))
  end

  def suppress_stdout
    real_stdout = $stdout
    stub_stdout = StringIO.new
    begin
      $stdout = stub_stdout
      yield
    ensure
      $stdout = real_stdout
    end
  end
end
