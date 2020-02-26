require 'rspec'
require 'swgr2rb'
require 'pry'
require_relative '../support/response_builder'
require_relative '../support/response_stub'
require_relative '../support/headers_stub'

RSpec.describe Swgr2rb::Response, :endpoint_class_config_generator do
  context 'create_response' do
    it 'create response with string data' do
      response = 'swagger => "2.0", info => "{:version=>"2.0"}"'
      generated_response = Swgr2rb::Response.new(response.to_json)

      expect(generated_response.body).to eq(response)
      expect(generated_response.code).to eq(200)
      expect(generated_response.headers).to eq('')
    end

    it 'create response with correct json data' do
      headers = HeadersStub.new('application/json')
      response_json = ResponseBuilder.new
                                     .set_host('win-k0tia6ggslb:9071')
                                     .set_swagger('2.0')
                                     .set_version('2.0')
                                     .set_headers(headers)
                                     .set_schemes('https')
                                     .json

      response = ResponseStub.new(response_json)
      generated_response = Swgr2rb::Response.new(response)
      expect(generated_response.code).to eq(200)
      expect(generated_response.headers.content_type).to eq('application/json')
      expect(generated_response.body).to eq(response_json[:body])
    end

    it 'create response with nil body' do
      response_json = ResponseBuilder.new
                                     .set_code(200)
                                     .set_headers('test')
                                     .json
      response = ResponseStub.new(response_json)
      response.set_body('null')
      generated_response = Swgr2rb::Response.new(response)

      expect(generated_response.body).to eq({})
      expect(generated_response.code).to eq(200)
      expect(generated_response.headers).to eq('test')
    end

    it 'error when trying to create response with non-nil body and 204 code' do
      response_json = ResponseBuilder.new
                                     .set_code(204)
                                     .set_headers('test')
                                     .json
      response = ResponseStub.new(response_json)
      response.set_body('false')
      expect { Swgr2rb::Response.new(response) }.to raise_error('Received non-null body in 204 No Content response')
    end
  end
end
