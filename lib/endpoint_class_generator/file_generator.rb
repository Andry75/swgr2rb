require_relative 'file_generator_constants'

module Swgr2rb
  class FileGenerator
    include FileGeneratorConstants

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
      create_target_dir(@opts[:target_dir]) unless @filename
      @filename ||= File.join(@opts[:target_dir],
                              "#{FileGeneratorConstants::CAMEL_CASE_TO_SNAKE_CASE.call(@opts[:name])}.rb")
    end

    def create_target_dir(dir_str)
      path_arr = dir_str.split('/')
      (0...path_arr.size).to_a.each do |i|
        Dir.mkdir(File.join(path_arr[0..i])) unless Dir.exist?(File.join(path_arr[0..i]))
      end
    end
  end
end
