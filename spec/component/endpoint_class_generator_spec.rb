require 'rspec'
require 'swgr2rb'
require_relative '../support/endpoint_class_generator_helper'

RSpec.describe Swgr2rb::EndpointClassGenerator, :endpoint_class_generator do
  context 'when generating initialize method' do
    it 'substitutes version parameter' do
      config = generate_endpoint_config(endpoint_path: 'api/v{version}/first',
                                        version: 1)
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).to match(/^\s*@end_point_path = proc { 'api\/v1\/first' }$/)

      config = generate_endpoint_config(endpoint_path: 'api/v{version}/first',
                                        version: 2)
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).to match(/^\s*@end_point_path = proc { 'api\/v2\/first' }$/)

      config = generate_endpoint_config(endpoint_path: 'api/endpoint/without/version')
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).to match(/^\s*@end_point_path = proc { 'api\/endpoint\/without\/version' }$/)
    end

    it 'works with one path parameter correctly' do
      path_params = [{ name: 'userId', schema: String }]
      config = generate_endpoint_config(endpoint_path: 'api/users/{userId}',
                                        request_params: { path: path_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_path = '@end_point_path = proc { |user_id| "api/users/#{user_id}" }'
      expect(lines.join("\n")).to match(/^\s*#{expected_path}$/)
    end

    it 'works with one query parameter correctly' do
      query_params = [{ name: 'status', schema: String }]
      config = generate_endpoint_config(endpoint_path: 'api/users',
                                        request_params: { query: query_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_path = '@end_point_path = proc { |status| "api/users?status=#{status}" }'
      expect(lines.join("\n")).to match(/^\s*#{expected_path}$/)
    end

    it 'works with multiple params correctly' do
      path_params = [{ name: 'parentId', schema: Integer },
                     { name: 'id', schema: Integer }]
      query_params = [{ name: 'name', schema: String }]
      config = generate_endpoint_config(endpoint_path: 'api/users/{parentId}/{id}',
                                        request_params: { path: path_params, query: query_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_path = '@end_point_path = proc { |id, name, parent_id| "api/users/#{parent_id}/#{id}?name=#\{name}" }'
      expect(lines.join("\n")).to match(/^\s*#{expected_path}$/)
    end
  end

  context 'when generating validate_response_schema method' do
    it 'works correctly when there is no response schema' do
      config = generate_endpoint_config
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expected_method = ['def validate_response_schema',
                         '  validate_response_code',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when there is a response schema' do
      response_schema = { name: String }
      config = generate_endpoint_config(expected_response: { schema: response_schema })
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expected_method = ['def validate_response_schema',
                         '  validate_response_code',
                         '  JsonValidator.validate(expected_schema, response.body)',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end
  end

  context 'when generating end_point_path method' do
    it 'works correctly when @end_point_path has no arguments' do
      config = generate_endpoint_config
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expected_method = ['def end_point_path',
                         '  @end_point_path.call',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when @end_point_path has one argument' do
      path_params = [{ name: 'userId', schema: Integer }]
      config = generate_endpoint_config(endpoint_path: 'api/users/{userId}',
                                        request_params: { path: path_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def end_point_path',
                         "  user_id = request_options[:params]['user_id'] if request_options[:params] && request_options[:params]['user_id']",
                         '  # TODO: Consider adding ability to load params from request_options[:sub_results]',
                         '  unless user_id',
                         '    raise "Harness error\n"\\',
                         "          'The api/users/{userId} '\\",
                         "          'requires user_id parameter'",
                         '  end',
                         '  @end_point_path.call(user_id)',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when @end_point_path has several arguments' do
      path_params = [{ name: 'parentId', schema: Integer },
                     { name: 'id', schema: Integer }]
      query_params = [{ name: 'name', schema: String }]
      config = generate_endpoint_config(endpoint_path: 'api/users/{parentId}/{id}',
                                        request_params: { path: path_params, query: query_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def end_point_path',
                         "  parent_id = request_options[:params]['parent_id'] if request_options[:params] && request_options[:params]['parent_id']",
                         "  id = request_options[:params]['id'] if request_options[:params] && request_options[:params]['id']",
                         "  name = request_options[:params]['name'] if request_options[:params] && request_options[:params]['name']",
                         '  # TODO: Consider adding ability to load params from request_options[:sub_results]',
                         '  unless parent_id && id && name',
                         '    raise "Harness error\n"\\',
                         "          'The api/users/{parentId}/{id} '\\",
                         "          'requires parent_id, id, name parameters'",
                         '  end',
                         '  @end_point_path.call(id, name, parent_id)',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'passes arguments to @end_point_path in the same order as in proc definition' do
      # when params are sorted alphabetically
      path_params = [{ name: 'a_arg', schema: String },
                     { name: 'b_arg', schema: String }]
      query_params = [{ name: 'c_arg', schema: String }]
      config = generate_endpoint_config(endpoint_path: 'api/{a_arg}/{b_arg}',
                                        request_params: { path: path_params, query: query_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expect(lines.join("\n"))
        .to match(code_lines_regexp('@end_point_path = proc { |a_arg, b_arg, c_arg| "api/#{a_arg}/#{b_arg}?c_arg=#{c_arg}" }'))
        .and match(code_lines_regexp('@end_point_path.call(a_arg, b_arg, c_arg)'))

      # when params are not sorted alphabetically
      path_params = [{ name: 'b_arg', schema: String },
                     { name: 'c_arg', schema: String }]
      query_params = [{ name: 'a_arg', schema: String }]
      config = generate_endpoint_config(endpoint_path: 'api/{b_arg}/{c_arg}',
                                        request_params: { path: path_params, query: query_params })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expect(lines.join("\n"))
        .to match(code_lines_regexp('@end_point_path = proc { |a_arg, b_arg, c_arg| "api/#{b_arg}/#{c_arg}?a_arg=#{a_arg}" }'))
        .and match(code_lines_regexp('@end_point_path.call(a_arg, b_arg, c_arg)'))
    end
  end

  context 'when generating generate_headers method' do
    it 'skips generate_headers when content type is application/json' do
      %i[get post put delete].each do |request_type|
        config = generate_endpoint_config(request_type: request_type)
        lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
        expect(lines.join("\n")).not_to match(code_lines_regexp('generate_headers'))
      end
    end

    it 'generates generate_headers when content type is multipart/form-data' do
      config = generate_endpoint_config(request_type: :multipart_post)
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expected_method = ['def generate_headers',
                         "  { 'Content-Type': 'multipart/form-data' }",
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end
  end

  context 'when generating generate_body method' do
    it 'works correctly when body is absent' do
      config = generate_endpoint_config
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expected_method = ['def generate_body',
                         '  nil',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when body is a single value' do
      body_param = { name: 'status', schema: String }
      config = generate_endpoint_config(request_params: { body: [body_param] })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def generate_body',
                         '  # TODO: Set meaningful default values in tmp',
                         "  tmp = 'string'",
                         '  # TODO: Consider adding ability to load params from request_options[:sub_results]',
                         "  tmp = request_options[:params]['status'] if request_options[:params] && request_options[:params]['status']",
                         '  tmp.to_json',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when body is an array of values' do
      body_param = { name: 'ids', schema: [Integer] }
      config = generate_endpoint_config(request_params: { body: [body_param] })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def generate_body',
                         '  # TODO: Set meaningful default values in tmp',
                         '  tmp = [',
                         '    0',
                         '  ]',
                         '  # TODO: Consider adding ability to load params from request_options[:sub_results]',
                         "  tmp = request_options[:params]['ids'] if request_options[:params] && request_options[:params]['ids']",
                         '  tmp = tmp.split(/,\s*/)',
                         '  tmp.to_json',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when body is a JSON' do
      body_schema = {
        email: String,
        id: Integer,
        fullName: String
      }
      config = generate_endpoint_config(request_params: { body: [{ name: 'Model', schema: body_schema }] })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def generate_body',
                         '  # TODO: Set meaningful default values in tmp',
                         '  tmp = {',
                         "    email: 'string',",
                         '    id: 0,',
                         "    fullName: 'string'",
                         '  }',
                         '  # TODO: Consider adding ability to load params from request_options[:sub_results]',
                         "  tmp[:email] = request_options[:params]['email'] if request_options[:params] && request_options[:params]['email']",
                         "  tmp[:id] = request_options[:params]['id'] if request_options[:params] && request_options[:params]['id']",
                         "  tmp[:fullName] = request_options[:params]['full_name'] if request_options[:params] && request_options[:params]['full_name']",
                         '  tmp.to_json',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly when body is an array of JSON' do
      body_schema = [{
        status: Swgr2rb::Boolean,
        randomFloat: Float
      }]
      config = generate_endpoint_config(request_params: { body: [{ name: 'Model', schema: body_schema }] })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def generate_body',
                         '  # TODO: Set meaningful default values in tmp',
                         '  tmp = [',
                         '    {',
                         "      status: false,",
                         '      randomFloat: 0.0',
                         '    }',
                         '  ]',
                         '  # TODO: Consider adding ability to load params from request_options[:sub_results]',
                         "  tmp.first[:status] = request_options[:params]['status'] if request_options[:params]&.key?('status')",
                         "  tmp.first[:randomFloat] = request_options[:params]['random_float'] if request_options[:params] && request_options[:params]['random_float']",
                         '  tmp.to_json',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly for a multipart request' do
      config = generate_endpoint_config(request_type: :multipart_post,
                                        request_params: { form_data: [{ name: 'file', schema: 'file' }] })

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_method = ['def generate_body',
                         '  # TODO: Add valid default file path',
                         "  file_path = 'misc/default_file_path'",
                         "  file_path = request_options[:params]['file_path'] if request_options[:params] && request_options[:params]['file_path']",
                         '  { filePath: file_path }',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'raises RuntimeError when schema contains invalid type' do
      params = Swgr2rb::EndpointClassConfig::RequestParams.new([], [], [], [])
      params.body << { name: 'status', schema: Hash }
      config = generate_endpoint_config(request_params: params)

      expect { Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines }
        .to raise_error(RuntimeError, 'Unexpected type: Hash')
    end
  end
end
