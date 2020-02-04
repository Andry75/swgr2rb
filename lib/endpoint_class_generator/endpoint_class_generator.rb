require_relative 'ruby_file_generator'
require_relative '../prototypes/json_schema_data_types'

module Swgr2rb
  class EndpointClassGenerator < RubyFileGenerator
    def generate_lines
      [generate_requires,
       generate_class_name,
       generate_modules_to_include,
       generate_initialize_method,
       generate_validate_response_schema_method,
       'private',
       generate_end_point_path_method,
       generate_generate_headers_method,
       generate_generate_body_method,
       'end'].compact.flatten
    end

    private

    def generate_requires
      RubyFileGeneratorConstants::REQUIRES.call([@opts[:parent_class]] + @opts[:modules_to_include])
    end

    def generate_class_name
      RubyFileGeneratorConstants::CLASS_NAME.call(@opts[:name], @opts[:parent_class][:name])
    end

    def generate_modules_to_include
      RubyFileGeneratorConstants::INCLUDES.call(@opts[:modules_to_include])
    end

    def generate_initialize_method
      RubyFileGeneratorConstants::INITIALIZE.call(generate_endpoint_path,
                                                  @config.request_type)
    end

    def generate_validate_response_schema_method
      RubyFileGeneratorConstants::VALIDATE_RESPONSE_SCHEMA.call(generate_schema_validation)
    end

    def generate_end_point_path_method
      unknown_params = path_params[:snake_case] + query_params[:snake_case]
      param_loading = generate_endpoint_path_param_loading(unknown_params)
      RubyFileGeneratorConstants::END_POINT_PATH.call(unknown_params,
                                                      param_loading)
          .compact.flatten
    end

    def generate_generate_headers_method
      RubyFileGeneratorConstants::GENERATE_HEADERS.call(@config.request_type)
    end

    def generate_generate_body_method
      RubyFileGeneratorConstants::GENERATE_BODY.call(generate_request_body(@config.request_params))
    end

    def generate_endpoint_path
      path = @config.endpoint_path.gsub('{', '#{')
      path_params[:camel_case].zip(path_params[:snake_case]) do |cc_param, sc_param|
        path.sub!(cc_param, sc_param)
      end
      path.sub!('#{version}', @config.version.to_s)
      if query_params[:camel_case].present?
        path << '?' << query_params[:camel_case].zip(query_params[:snake_case])
                           .map { |cc, sc| "#{cc}=\#{#{sc}}" }.join('&')
      end
      proc_params = path_params[:snake_case] + query_params[:snake_case]
      if proc_params.empty?
        "proc { '#{path}' }"
      else
        "proc { |#{proc_params.sort.join(", ")}| \"#{path}\" }"
      end
    end

    def path_params
      @path_params ||= generate_params(@config.request_params.path.reject { |p| p[:name] == 'version' })
    end

    def query_params
      @query_params ||= generate_params(@config.request_params.query)
    end

    def generate_params(params)
      camel_case_params = params.map { |hsh| hsh[:name] }
      snake_case_params = camel_case_params.map { |s| RubyFileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call(s) }
      { camel_case: camel_case_params, snake_case: snake_case_params }
    end

    def generate_schema_validation
      RubyFileGeneratorConstants::JSON_VALIDATOR_VALIDATE_SCHEMA if @config.expected_response.schema.present?
    end

    def generate_endpoint_path_param_loading(params)
      if params.present?
        lines = params.map do |param|
          RubyFileGeneratorConstants::GET_PARAM_FROM_REQUEST_OPTIONS.call(param)
        end
        lines << RubyFileGeneratorConstants::COMMENT_ADD_SUB_RESULTS
        lines << RubyFileGeneratorConstants::RAISE_UNLESS_PARAMS_PASSED.call(params, @config.endpoint_path)
        lines.flatten
      end
    end

    def generate_request_body(params)
      case params
      in { body: [{ schema: } => param, *] }
        [RubyFileGeneratorConstants::COMMENT_SET_VALID_VALUES,
         "tmp = #{generate_default_request_body(schema)}",
         RubyFileGeneratorConstants::COMMENT_ADD_SUB_RESULTS,
         generate_request_body_set_params(param),
         'tmp.to_json'].flatten
      in { form_data: [Hash, *] }
        RubyFileGeneratorConstants::MULTIPART_REQUEST_BODY
      else
        'nil'
      end
    end

    def generate_default_request_body(schema)
      if schema.instance_of?(Class) || schema == Boolean
        default_value_for_type(schema)
      elsif schema.is_a?(Array)
        "[\n" + generate_default_request_body(schema.first) + "\n]"
      elsif schema.is_a?(Hash)
        schema = schema.map { |name, type| "#{name}: #{generate_default_request_body(type)}," }
                     .join("\n").sub(/,\Z/, '')
        "{\n" + schema + "\n}"
      end
    end

    def generate_request_body_set_params(params)
      case params
      in { schema: Class | Boolean => schema, name: }
        "tmp = #{RubyFileGeneratorConstants::GET_PARAM_FROM_REQUEST_PARAMS.call(name, schema)}"
      in { schema: [Hash => item, *] }
        item.map do |name, type|
          "tmp.first[:#{name}] = #{RubyFileGeneratorConstants::GET_PARAM_FROM_REQUEST_PARAMS.call(name, type)}"
        end
      in { schema: [type], name: }
        ["tmp = #{RubyFileGeneratorConstants::GET_PARAM_FROM_REQUEST_PARAMS.call(name, type)}",
         'tmp = tmp.split(/,\s*/)']
      in { schema: Hash => schema }
        schema.map do |name, type|
          "tmp[:#{name}] = #{RubyFileGeneratorConstants::GET_PARAM_FROM_REQUEST_PARAMS.call(name, type)}"
        end
      end
    end

    def default_value_for_type(type)
      if type.is_a?(Array)
        "[#{default_value_for_type(type.first)}]"
      elsif type == String
        "'string'"
      elsif type == Integer
        '0'
      elsif type == Float
        '0.0'
      elsif type == Boolean
        'false'
      else
        raise "Unexpected type: #{type}"
      end
    end
  end
end
