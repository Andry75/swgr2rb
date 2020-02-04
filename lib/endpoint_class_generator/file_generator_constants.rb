require_relative '../prototypes/json_schema_data_types'

module Swgr2rb
  module FileGeneratorConstants
    REQUIRES = proc do |required|
      required.map { |hsh| "require_relative '#{hsh[:path].sub(/\.rb$/, '')}'" }.join("\n") + "\n"
    end

    CLASS_NAME = proc { |class_name, parent_class_name| "class #{class_name} < #{parent_class_name}" }
    MODULE_NAME = proc { |module_name| "module #{module_name}" }

    INCLUDES = proc do |modules|
      modules.map { |hsh| "include #{hsh[:name]}" }.join("\n") + "\n"
    end

    INITIALIZE = proc do |endpoint_path, supported_requests|
      ['def initialize',
       "  @end_point_path = #{endpoint_path}",
       "  @supportable_request_types = %w[#{supported_requests}]",
       'end']
    end

    VALIDATE_RESPONSE_SCHEMA = proc do |schema_validation|
      ['def validate_response_schema',
       "  validate_response_code",
       schema_validation,
       'end'].compact.flatten
    end

    END_POINT_PATH = proc do |params, param_loading|
      ['def end_point_path',
       param_loading,
       "  @end_point_path.call#{params.empty? ? '' : "(#{params.sort.join(', ')})"}",
       'end'].compact.flatten
    end

    GENERATE_HEADERS = proc do |request_type|
      if request_type == 'multipart_post'
        ['def generate_headers',
         '  {',
         "    'Content-Type': 'multipart/form-data',",
         "    'authorization': \"Bearer \#{access_token}\"",
         '  }',
         'end']
      end
    end

    GENERATE_BODY = proc do |body|
      ['def generate_body',
       (body ? body : 'nil'),
       'end'].flatten
    end

    GET_PARAM_FROM_REQUEST_OPTIONS = proc do |param|
      "#{param} = request_options[:params]['#{param}'] if request_options[:params] && request_options[:params]['#{param}']"
    end
    COMMENT_ADD_SUB_RESULTS = '# TODO: Consider adding ability to load params from request_options[:sub_results]'.freeze
    RAISE_UNLESS_PARAMS_PASSED = proc do |params, endpoint_path|
      ["unless #{params.join(' && ')}",
       '  raise "Harness error\n"\\',
       "        'The #{endpoint_path} '\\",
       "        'requires #{params.join(', ')} parameter#{params.size > 1 ? 's' : ''}'",
       'end']
    end

    JSON_VALIDATOR_VALIDATE_SCHEMA = 'JsonValidator.validate(expected_schema, response.body)'.freeze

    COMMENT_SET_VALID_VALUES = '# TODO: Set meaningful default values in tmp'.freeze
    GET_PARAM_FROM_REQUEST_PARAMS = proc do |name, type|
      name = CAMEL_CASE_TO_SNAKE_CASE.call(name)
      line = "request_options[:params]['#{name}'] if request_options[:params]"
      line << (type == Boolean ? "&.key?('#{name}')" : " && request_options[:params]['#{name}']")
      line
    end
    MULTIPART_REQUEST_BODY = ['# TODO: Add valid default file path',
                              "file_path = 'misc/default_file_path'",
                              "file_path = request_options[:params]['file_path'] if request_options[:params] && request_options[:params]['file_path']",
                              '{ filePath: file_path }'].freeze

    EXPECTED_CODE = proc do |code|
      ['def expected_code',
       code.to_s,
       'end']
    end

    EXPECTED_SCHEMA = proc do |schema|
      ['def expected_schema',
       schema,
       'end'].flatten
    end

    # Helper constants

    CAMEL_CASE_TO_SNAKE_CASE = proc do |str|
      str.to_s.split(/([[:upper:]][[:lower:]]+)/)
          .select(&:present?)
          .map(&:downcase)
          .join('_')
          .gsub(/_+/, '_')
    end

    SNAKE_CASE_TO_CAMEL_CASE = proc do |str|
      str.to_s.split('_').map(&:capitalize).join
    end
  end
end
