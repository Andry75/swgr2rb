class SwaggerJsonDefinitionBuilder
  def initialize
    @json = {
      properties: {},
      type: 'object'
    }
  end

  def json
    if @json[:properties].empty?
      raise "Invalid definition built: 'properties' must not be empty"
    end
    @json
  end

  def build_definition(schema)
    schema.each do |name, type|
      @json[:properties][name.to_s] = generate_schema(type)
    end
    self
  end

  private

  def generate_schema(type)
    case type
    when Class, Module
      { type: class_to_json_string(type) }
    when Array
      {
        type: 'array',
        items: generate_schema(type.first)
      }
    when Symbol
      { '$ref': "#/definitions/#{type}" }
    else
      raise "Invalid argument passed to SwaggerJsonDefinitionBuilder: "\
            "schema hash values can be:\n"\
            "1) a Class/Module (e.g. String, Swgr2rb::Boolean)\n"\
            "2) an array (e.g. [Integer])\n"\
            "3) a Symbol if it is a reference to a definition (e.g. :FirstModel)"
    end
  end

  def class_to_json_string(class_obj)
    if class_obj == Float
      'number'
    elsif class_obj == Hash
      'object'
    else
      class_obj.to_s.sub(/^Swgr2rb::/, '').downcase
    end
  end
end
