require 'rspec'
require 'swgr2rb'
require_relative '../support/endpoint_class_generator_helper'

RSpec.describe Swgr2rb::EndpointClassGenerator, :endpoint_class_generator do
  context 'when generating initialize method' do
    it 'substitutes version parameter' do
      config = default_endpoint_config(endpoint_path: 'api/v{version}/first',
                                       version: 1)
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).to match(/^\s*@end_point_path = proc { 'api\/v1\/first' }$/)

      config = default_endpoint_config(endpoint_path: 'api/v{version}/first',
                                       version: 2)
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).to match(/^\s*@end_point_path = proc { 'api\/v2\/first' }$/)

      config = default_endpoint_config(endpoint_path: 'api/endpoint/without/version')
      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).to match(/^\s*@end_point_path = proc { 'api\/endpoint\/without\/version' }$/)
    end

    it 'works with one path parameter correctly' do
      path_params = [{ name: 'userId', schema: String }]
      config = default_endpoint_config(endpoint_path: 'api/users/{userId}',
                                       request_params: Swgr2rb::EndpointClassConfig::RequestParams.new(path_params, [], [], []))

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_path = '@end_point_path = proc { |user_id| "api/users/#{user_id}" }'
      expect(lines.join("\n")).to match(/^\s*#{expected_path}$/)
    end

    it 'works with one query parameter correctly' do
      query_params = [{ name: 'status', schema: String }]
      config = default_endpoint_config(endpoint_path: 'api/users',
                                       request_params: Swgr2rb::EndpointClassConfig::RequestParams.new([], query_params, [], []))

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_path = '@end_point_path = proc { |status| "api/users?status=#{status}" }'
      expect(lines.join("\n")).to match(/^\s*#{expected_path}$/)
    end

    it 'works with multiple params correctly' do
      path_params = [{ name: 'parentId', schema: Integer },
                     { name: 'id', schema: Integer }]
      query_params = [{ name: 'name', schema: String }]
      config = default_endpoint_config(endpoint_path: 'api/users/{parentId}/{id}',
                                       request_params: Swgr2rb::EndpointClassConfig::RequestParams.new(path_params, query_params, [], []))

      lines = Swgr2rb::EndpointClassGenerator.new(config, {}).generate_lines

      expected_path = '@end_point_path = proc { |id, name, parent_id| "api/users/#{parent_id}/#{id}?name=#\{name}" }'
      expect(lines.join("\n")).to match(/^\s*#{expected_path}$/)
    end
  end
end
