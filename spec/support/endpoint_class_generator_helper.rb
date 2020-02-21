module EndpointClassGeneratorHelper
  def generate_endpoint_config(opts = {})
    Swgr2rb::EndpointClassConfig.new(opts[:endpoint_path] || 'api/default/endpoint/path',
                                     opts[:request_type] || 'get',
                                     generate_expected_response(opts[:expected_response]),
                                     generate_request_params(opts[:request_params]),
                                     opts[:operation_id] || 'GetRequest',
                                     opts[:version] || 1)
  end

  def code_lines_regexp(lines)
    if lines.is_a?(Array)
      /#{lines.map { |line| escape_code_line(line) }.join("\n")}/
    else
      /#{escape_code_line(lines)}/
    end
  end

  private

  def generate_expected_response(opts)
    opts ||= {}
    Swgr2rb::EndpointClassConfig::ExpectedResponse.new(opts[:code] || 200,
                                                       opts[:schema] || nil)
  end

  def generate_request_params(opts)
    opts ||= {}
    Swgr2rb::EndpointClassConfig::RequestParams.new(opts[:path] || [],
                                                    opts[:query] || [],
                                                    opts[:body] || [],
                                                    opts[:form_data] || [])
  end

  def escape_code_line(line)
    "\s*#{Regexp.escape(line.lstrip)}"
  end
end
