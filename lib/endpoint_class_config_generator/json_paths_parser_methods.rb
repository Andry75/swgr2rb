module Swgr2rb
  module JsonPathsParserMethods
    def generate_request_type(request_type, request_properties)
      if request_properties[:parameters].find { |param| param[:in] == 'formData' && param[:type] == 'file' }
        'multipart_post'
      else
        request_type
      end
    end

    def generate_expected_response(request_properties)
      EndpointClassConfig::ExpectedResponse.new(generate_expected_response_code(request_properties),
                                                generate_expected_response_schema(request_properties))
    end

    def generate_request_params(request_properties)
      params = EndpointClassConfig::RequestParams.new([], [], [], [])
      request_properties[:parameters].select { |hsh| hsh[:required] }.each do |param_hash|
        param_schema = case param_hash
        in { schema: }
          parse_field_properties(schema)
        in { type: }
          field_type_to_ruby_class(type)
                       end
        params.send(param_hash[:in] == 'formData' ? :form_data : param_hash[:in].to_sym) << {
            name: param_hash[:name],
            schema: param_schema
        }
      end
      params
    end

    def generate_operation_id(request_properties)
      request_properties[:operationId]
    end

    def generate_version
      @json[:info][:version].to_i
    end

    private

    def generate_expected_response_code(request_hash)
      request_hash[:responses].keys.map(&:to_s).select { |k| k.match?(/^2/) }.last.to_i
    end

    def generate_expected_response_schema(request_hash)
      successful_response = request_hash[:responses].select { |code, _response| code.to_s.match?(/^2/) }.to_a.last[1]
      case successful_response
      in { schema: { type: 'array', items: } }
        get_response_item_schema(items)
      in { schema: }
        get_response_item_schema(schema)
      else
        nil
      end
    end

    def get_response_item_schema(schema_properties)
      case schema_properties
      in { '$ref': ref }
        @schema_definitions[get_schema_name(ref)]
      in { type: }
        field_type_to_ruby_class(type)
      end
    end
  end
end
