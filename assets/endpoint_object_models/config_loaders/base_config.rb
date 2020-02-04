class BaseConfig
  attr_accessor :config_file
  def initialize(config_file)
    @config_file = config_file
    create_attribute_accessors
    self
  end

  private

  def create_attribute_accessors
    config_file.each do |k, v|
      create_attribute_reader(k, v)
    end
  end

  def create_attribute_reader(key, value)
    case value
    when Hash
      instance_variable_set("@#{key}", BaseConfig.new(value))
    else
      instance_variable_set("@#{key}", value)
    end
    self.class.send(:define_method, key) do
      instance_variable_get("@#{key}")
    end
  end
end
