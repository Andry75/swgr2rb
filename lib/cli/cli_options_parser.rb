# frozen_string_literal: true

require 'optparse'
require 'swgr2rb'

module Swgr2rb
  # CliOptionsParser parses arguments received from
  # command line and generates parameters for endpoint generation.
  class CliOptionsParser
    def initialize
      @params = default_params
    end

    def parse(args)
      option_parser = OptionParser.new do |parser|
        define_options(parser)
      end
      parse_options(option_parser, args)
      path = parse_swagger_path_from_args(args)
      [path, @params]
    end

    private

    def default_params
      {
        target_dir: ScaffoldGeneratorConstants::ENDPOINT_MODELS_DIR,
        component: 'component1',
        update_only: false,
        rewrite_schemas: true,
        from_scratch: false
      }
    end

    def define_options(opts)
      define_banner(opts)
      define_target_dir_option(opts)
      define_component_option(opts)
      define_update_only_option(opts)
      define_rewrite_schemas_option(opts)
      define_from_scratch_option(opts)
      define_help_option(opts)
    end

    def parse_options(options_parser, args)
      options_parser.parse(args)
    rescue OptionParser::ParseError => e
      raise Swgr2rbError, e.message
    end

    def parse_swagger_path_from_args(args)
      path = args[0]
      if path.nil? || !(url?(path) || json_file_path?(path))
        raise Swgr2rbError,
              "Provided Swagger URL/file path '#{path}' is neither "\
              'a URL nor a path of an existing JSON file'
      end
      path.to_s
    end

    def define_banner(opts)
      opts.banner = "Usage:\tswgr2rb SWAGGER_URL|FILE_PATH [OPTIONS]"
      opts.separator("\nTo generate a new testing framework from scratch:\n\t"\
                     'swgr2rb SWAGGER_URL|FILE_PATH --from-scratch'\
                     " [-c COMPONENT]\n\n"\
                     "To update an existing testing framework:\n\t"\
                     'swgr2rb SWAGGER_URL|FILE_PATH [-t TARGET_DIR]'\
                     "[-c COMPONENT]\n\t"\
                     '     [--[no-]update-only] [--[no-]rewrite-schemas]')
      opts.separator('')
      opts.separator('Options:')
    end

    def define_target_dir_option(opts)
      opts.on('-t TARGET_DIR', '--target-dir TARGET_DIR', String,
              'Target directory for endpoint object models',
              "(the directory that contains components' folders).",
              "Default: #{@params[:target_dir]}.") do |dir|
        @params[:target_dir] = dir
      end
    end

    def define_component_option(opts)
      opts.on('-c COMPONENT', '--component COMPONENT', String,
              'Component name for endpoint classes. For a new',
              'project, a directory named like this will be created',
              'inside the target directory, and all the generated',
              'endpoint object models will be located inside.',
              "Default: #{@params[:component]}.") do |component|
        @params[:component] = component
      end
    end

    def define_update_only_option(opts)
      opts.on('--[no-]update-only', TrueClass,
              'Do not create new files, only update existing. This',
              'option is useful when there are new (previously',
              'untested) endpoints in Swagger. '\
              "Default: #{@params[:update_only]}.") do |update_only|
        @params[:update_only] = update_only
      end
    end

    def define_rewrite_schemas_option(opts)
      opts.on('--[no-]rewrite-schemas', TrueClass,
              'Rewrite schema modules (located in',
              'TARGET_DIR/COMPONENT/object_model_schemas)',
              'if they already exist. '\
              "Default: #{@params[:rewrite_schemas]}.") do |rewrite_schemas|
        @params[:rewrite_schemas] = rewrite_schemas
      end
    end

    def define_from_scratch_option(opts)
      opts.on('--from-scratch', TrueClass,
              'Generate new testing framework. Will create',
              "a directory named 'harness' and generate the scaffold",
              'of the framework inside. '\
              "Default: #{@params[:from_scratch]}.") do |from_scratch|
        @params[:from_scratch] = from_scratch
      end
    end

    def define_help_option(opts)
      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end

    def url?(path)
      URI.extract(path).present?
    end

    def json_file_path?(path)
      path.end_with?('.json') && File.exist?(path)
    end
  end
end
