require_relative 'swagger_json_definition_builder'

class SwaggerJsonBuilder
  attr_reader :json

  def initialize
    @json = {
      info: {
        version: '1.0'
      },
      definitions: {},
      paths: {}
    }
  end

  # definitions_hsh: hash like { ModelOne: { name: String }, ModelTwo: { names: [:ModelOne] } }
  def build_definitions(definitions_hsh)
    definitions = definitions_hsh.map do |model_name, schema|
      { model_name => SwaggerJsonDefinitionBuilder.new.build_definition(schema).json }
    end
    @json[:definitions].merge!(*definitions)
    self
  end

  # paths: hash like { 'endpoint/path': [<json built with SwaggerJsonPathBuilder>] }
  def build_paths(paths)
    paths.each do |path, requests|
      @json[:paths][path] ||= {}
      @json[:paths][path].merge!(requests.reduce(&:merge))
    end
    self
  end

  def set_version(version)
    @json[:info][:version] = version.to_s
    self
  end
end
