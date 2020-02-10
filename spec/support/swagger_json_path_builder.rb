class SwaggerJsonPathBuilder
  def initialize(request_type)
    @json = {
      request_type => {
        operationId: "#{request_type.capitalize}_#{Time.now.strftime("%S%6N")}",
        parameters: [],
        responses: {}
      }
    }
  end

  def json
    if @json.values.first[:responses].empty?
      raise "Invalid json built: 'responses' must not be empty"
    end
    @json
  end

  def build_parameter(name, where, schema)
    validate_parameter_where_arg(where)
    param = {
      name: name.to_s,
      in: where.to_s,
      required: true
    }.merge(generate_parameter_schema(schema))
    @json.values.first[:parameters] << param
    self
  end

  def build_response(code, schema = nil)
    response_schema = schema ? generate_response_schema(schema) : {}
    @json.values.first[:responses].merge!({ code.to_s => response_schema })
    self
  end

  def set_operation_id(operation_id)
    @json.values.first[:operationId] = operation_id.to_s
    self
  end

  private

  def validate_parameter_where_arg(where)
    valid_where = %w[path query body formData]
    unless valid_where.include?(where.to_s)
      raise "Invalid argument passed to SwaggerJsonPathBuilder: 'where' argument must be one of #{valid_where}"
    end
  end

  def generate_parameter_schema(schema)
    sch = generate_schema(schema)
    if sch[:type].is_a?(Class) || sch[:type].is_a?(Module)
      sch
    else
      { schema: sch }
    end
  end

  def generate_response_schema(schema)
    { schema: generate_schema(schema) }
  end

  def generate_schema(schema)
    case schema
    when Class, Module
      { type: class_to_json_string(schema) }
    when Array
      {
        type: 'array',
        items: generate_schema(schema.first)
      }
    when Symbol
      { '$ref': "#/definitions/#{schema}" }
    else
      raise "Invalid argument passed to SwaggerJsonPathBuilder: "\
            "'schema' argument must be:\n"\
            "1) a Class/Module (e.g. String, Swgr2rb::Boolean)\n"\
            "2) an array (e.g. [Integer])\n"\
            "3) a Symbol if it is a reference to a definition (e.g. :FirstModel)"
    end
  end

  def class_to_json_string(class_obj)
    if class_obj == Float
      'number'
    else
      class_obj.to_s.sub(/^Swgr2rb::/, '').downcase
    end
  end
end
