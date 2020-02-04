require_relative 'base_endpoint_object_model_constants'

module BaseEndpointObjectModelMethods
  include BaseEndpointObjectModelConstants

  def send_request(type, params, sub_results = nil)
    if request_type_support?(type)
      @request_options = {
          type: type,
          params: params,
          sub_results: sub_results
      }
      @request = Request.new(end_point_path, type,
                             generate_headers, generate_body)
      @response = ConductorSender.send_request(request)
    else
      raise "Harness setup error!\n "\
            "#{type} do not supports by the #{end_point_path}\n"\
            'list of the supportable types: '\
            "#{supportable_request_types.join(', ')}"
    end
  end

  def validate_error_response(error_code)
    unless error_code == response.code
      raise "The #{response.code} is wrong for #{self.class} endpoint\n"\
            "Expected : #{error_code}\n"\
            "Actual   : #{response.code}"
    end
    send("#{response.code.to_i.humanize.gsub(' ', '_')}_error_code_schema")
  end

  def results
    response.body
  end

  private

  def validate_response_code
    unless response.code == expected_code
      raise "Invalid response code\n"\
            "Expected: #{expected_code}\n"\
            "Actual: #{response.code}"
    end
  end

  def compare_error_body(expected, actual)
    expected_keys = expected.keys.sort
    actual_keys = actual.keys.sort

    unless expected_keys == actual_keys
      raise "The body for error is wrong \n"\
            "Expected:\n"\
            "#{expected_keys}\n"\
            "Actual:\n"\
            "#{actual_keys}"
    end

    expected.each do |k, v|
      case v
      when Hash
        compare_error_body(expected[k], actual[k])
      else
        unless expected[k] == actual[k]
          raise "The value of body is wrong\n"\
                "Expected:\n"\
                "#{k}: #{expected[k]}\n"\
                "Actual:\n"\
                "#{k}: #{actual[k]}"
        end
      end
    end
  end

  def generate_headers
    { 'Content-Type': 'application/json' }
  end

  def request_type_support?(type)
    supportable_request_types.include?(type)
  end
end
