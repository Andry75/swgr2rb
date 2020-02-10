module EndpointClassGeneratorHelper
  def default_endpoint_config(opts = {})
    Swgr2rb::EndpointClassConfig.new(opts[:endpoint_path] || 'api/default/endpoint/path',
                                     opts[:request_type] || 'get',
                                     opts[:expected_response] || Swgr2rb::EndpointClassConfig::ExpectedResponse.new(200, nil),
                                     opts[:request_params] || Swgr2rb::EndpointClassConfig::RequestParams.new([], [], [], []),
                                     opts[:operation_id] || 'GetRequest',
                                     opts[:version] || 1)
  end
end
