# frozen_string_literal: true

require_relative 'base_config'

class ConductorConfigLoader
  class << self
    def load
      current_dir = __FILE__.scan(%r{(.*/harness/)(.*)}m).flatten.first
      file = YAML.load_file(File.join(current_dir,
                                      '/configs',
                                      'conductor_sender_configs.yaml'))
      ConductorConfig.new(file)
    end
  end
end

class ConductorConfig < BaseConfig
end
