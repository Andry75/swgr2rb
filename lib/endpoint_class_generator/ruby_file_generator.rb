require 'fileutils'
require_relative 'ruby_file_generator_constants'

module Swgr2rb
  class RubyFileGenerator
    include RubyFileGeneratorConstants

    # opts can include:
    #   name: class/module name
    #   rewrite: if set to true, rewrite the existing file if it already exists
    #   target_dir: directory where the class/module will be created
    #   update_only: if set to true, do not create new file, only update existing
    def initialize(class_config, opts)
      @config = class_config
      @opts = opts
    end

    def generate_file
      if (File.exist?(filename) && !@opts[:rewrite]) ||
          (!File.exist?(filename) && @opts[:update_only])
        return
      end
      File.open(filename, 'w') do |file|
        file.write(generate_lines.join("\n"))
      end
    end

    private

    def filename
      unless @filename
        create_target_dir(@opts[:target_dir])
        @filename = File.join(@opts[:target_dir],
                              "#{RubyFileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call(@opts[:name])}.rb")
      end
      @filename
    end

    def create_target_dir(dir_str)
      FileUtils.mkdir_p(dir_str) unless Dir.exist?(dir_str)
    end
  end
end
