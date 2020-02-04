module Swgr2rb
  class EndpointClassConfig
    attr_reader :endpoint_path, :request_type, :expected_response, :request_params, :version
    attr_accessor :operation_id

    def initialize(endpoint_path, request_type, expected_response, request_params, operation_id, version)
      @endpoint_path = endpoint_path
      @request_type = request_type
      @expected_response = expected_response
      @request_params = request_params
      @operation_id = operation_id
      @version = version
    end

    ExpectedResponse = Struct.new(:code, :schema)
    RequestParams = Struct.new(:path, :query, :body, :form_data)
  end
end
