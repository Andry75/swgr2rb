require 'rspec'
require 'swgr2rb'
require 'pry'
require_relative '../support/headers_stub'


RSpec.describe Swgr2rb::Request, :endpoint_class_config_generator do
  context 'create_request' do
    it 'create request with test data' do
      endpoint_name = 'test-endpoint'
      type = 'get'
      headers = HeadersStub.new('application/json')
      body = 'swagger => "2.0", info => "{:version=>"2.0"}"'
      generated_request = Swgr2rb::Request.new(endpoint_name, type, headers, body)

      expect(generated_request.body).to eq(body)
      expect(generated_request.endpoint_name).to eq(endpoint_name)
      expect(generated_request.headers.content_type). to eq(headers.content_type)
      expect(generated_request.type).to eq(type)
    end
  end
end
