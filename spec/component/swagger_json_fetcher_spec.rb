require 'rspec'
require 'swgr2rb'
require 'fileutils'
require 'json'

RSpec.describe Swgr2rb::SwaggerJsonFetcher do
  context 'when using Swagger URL' do
    it 'generates and sends correct API request' do
      swagger_url = 'localhost:8080/swagger'
      request_obj = Swgr2rb::Request.new(swagger_url, 'get', nil, nil)

      request_class = class_spy(Swgr2rb::Request)
                        .as_stubbed_const(transfer_nested_constants: true)
      allow(request_class)
        .to receive(:new)
        .and_return(request_obj)

      conductor_sender_class = class_spy(Swgr2rb::ConductorSender)
                                 .as_stubbed_const(transfer_nested_constants: true)
      allow(conductor_sender_class)
        .to receive(:send_request)
        .and_return(Swgr2rb::Response.new('{"fake":"response"}'))

      json = Swgr2rb::SwaggerJsonFetcher.get_swagger_json(swagger_url)

      expect(request_class)
        .to have_received(:new)
        .with(swagger_url, 'get', nil, nil)
      expect(conductor_sender_class)
        .to have_received(:send_request)
        .with(request_obj)
      expect(json).to eq({ fake: 'response' })
    end
  end

  context 'when using JSON file path' do
    let(:filename) { 'tmp/test.json' }
    before(:each) { Dir.mkdir('tmp') }
    after(:each) { FileUtils.rm_r('tmp') }

    it 'reads file successfully if its content is valid' do
      expected_json = {
        name: 'string!',
        randomFloat: 3.8,
        child: { bool: true }
      }
      File.open(filename, 'w') { |file| file.write(expected_json.to_json) }
      actual_json = Swgr2rb::SwaggerJsonFetcher.get_swagger_json(filename)
      expect(actual_json).to eq(expected_json.deep_transform_keys(&:to_s))
    end

    it 'raises error if JSON cannot be read' do
      File.open(filename, 'w') { |file| file.write('{invalid: json}') }
      expect { Swgr2rb::SwaggerJsonFetcher.get_swagger_json(filename) }
        .to raise_error(Swgr2rb::Swgr2rbError,
                        /An error occurred while trying to read JSON file '#{Regexp.escape(filename)}'/)
    end
  end
end
