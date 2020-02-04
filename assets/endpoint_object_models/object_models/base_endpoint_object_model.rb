# frozen_string_literal: true

class BaseEndpointObjectModel
  attr_accessor :request_options, :request, :response, :end_point_path,
                :supportable_request_types, :subdomain, :credentials

  def send_request(_type, _params)
    raise 'This is abstract class'
  end

  def validate_response_schema
    raise 'This is abstract class'
  end

  def validate_error_response(_error_code)
    raise 'This is abstract class'
  end

  def results
    raise 'This is abstract class'
  end
end
