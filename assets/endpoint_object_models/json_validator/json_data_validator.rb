class JsonDataValidator
  class << self
    def validate(expected_data, actual_data)
      begin
        validate_recursively(expected_data, actual_data)
      rescue RuntimeError => e
        raise "#{e.message}\n\n"\
              "Full expected response:\n#{expected_data}\n\n"\
              "Full actual response:\n#{actual_data}"
      end
    end

    private

    def validate_recursively(expected_data, actual_data, key_name = nil)
      case expected_data
      when Array
        validate_response_size(expected_data, actual_data, key_name)
        expected_data.zip(actual_data).each do |expected, actual|
          validate_recursively(expected, actual)
        end
      when Hash
        expected_data.each do |exp_key, exp_value|
          validate_recursively(exp_value, actual_data[exp_key], exp_key)
        end
      else
        unless expected_data.to_s == actual_data.to_s ||
            (expected_data.is_a?(Regexp) && expected_data.match?(actual_data.to_s))
          raise "Unexpected value in response body#{key_name ? " for key '#{key_name}'" : ''}\n"\
                "Expected: #{expected_data}\n"\
                "Actual: #{actual_data}"
        end
      end
    end

    def validate_response_size(expected_data, actual_data, key_name = nil)
      unless expected_data.size == actual_data.size
        raise "Unexpected number of objects in response body#{key_name ? " for key '#{key_name}'" : ''}\n"\
              "Expected: #{expected_data.size}\n"\
              "Actual: #{actual_data.size}"
      end
    end
  end
end
