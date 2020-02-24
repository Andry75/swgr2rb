module Swgr2rb
  module JsonSchemaDefinitionsParserMethods
    def generate_response_schema_definitions
      @json[:definitions].keys.each do |name|
        generate_schema_definition(name)
      end
    end

    private

    def generate_schema_definition(name)
      @schema_definitions[name] ||= parse_schema_definition(@json[:definitions][name], name)
    end

    def parse_schema_definition(hash, name = '')
      case hash
      in { type: 'object', properties: }
        properties.map do |field_name, field_properties|
          { field_name.to_sym => parse_field_properties(field_properties, [name, field_name.to_sym]) }
        end.reduce(&:merge)
      end
    end

    def parse_field_properties(field_properties, parent_schema_names = [])
      case field_properties
      in { type: 'array', items: }
        [parse_single_field(items, parent_schema_names)]
      else
        parse_single_field(field_properties, parent_schema_names)
      end
    end

    def parse_single_field(field_hash, parent_schema_names)
      case field_hash
      in { '$ref': ref }
        get_child_schema(ref, parent_schema_names)
      in { type: }
        field_type_to_ruby_class(type)
      end
    end

    def get_child_schema(ref, parent_schema_names)
      schema_name = get_schema_name(ref)
      parent_schema_names.include?(schema_name) ? Hash : generate_schema_definition(schema_name)
    end

    def field_type_to_ruby_class(type)
      case type
      when 'number' then Float
      when 'object' then Hash
      else eval(type.to_s.capitalize)
      end
    end

    def get_schema_name(ref)
      ref.split('/').last.to_sym
    end
  end
end
