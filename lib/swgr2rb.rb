# frozen_string_literal: true
require 'optparse'
require_relative 'endpoint_class_generator/endpoint_classes_generator'
require_relative 'scaffold_generator/scaffold_generator'
require_relative 'scaffold_generator/scaffold_generator_constants'

module Swgr2rb
  class Main
    def initialize(args)
      @args = args
      @params = default_params
    end

    def execute
      url = parse_cli_arguments(generate_option_parser)

      if @params[:from_scratch]
        @params.merge!(target_dir: File.join(ScaffoldGeneratorConstants::HARNESS_DIR,
                                             ScaffoldGeneratorConstants::ENDPOINT_MODELS_DIR),
                       update_only: false)
        puts 'Generating scaffold of the testing framework...'
        ScaffoldGenerator.generate_scaffold
      end

      puts "Generating endpoint classes in #{@params[:target_dir]}..."
      EndpointClassesGenerator.new(url, @params).generate_endpoint_classes

      if @params[:from_scratch]
        puts 'Generating example feature file...'
        ScaffoldGenerator.generate_example_feature_file(@params)
      end

      puts 'Formatting generated endpoint object models with rubocop...'
      format_target_dir_with_rubocop
      puts 'Done!'
    end

    private

    def default_params
      {
          target_dir: ScaffoldGeneratorConstants::ENDPOINT_MODELS_DIR,
          component: 'component1',
          update_only: false,
          rewrite_schemas: true,
          rewrite_classes: false,
          from_scratch: false
      }
    end

    def generate_option_parser
      OptionParser.new do |opts|
        opts.banner = "Usage:\tswgr2rb SWAGGER_URL [OPTIONS]"
        opts.separator('')
        opts.separator("To generate a new project from scratch:\n\t"\
                       "swgr2rb SWAGGER_URL --from-scratch [-c COMPONENT]\n"\
                       "To update an existing project:\n\t"\
                       "swgr2rb SWAGGER_URL [-t TARGET_DIR] [-c COMPONENT] [--[no-]update-only] [--[no-]rewrite-schemas] [--[no-]rewrite-classes]")
        opts.separator('')
        opts.separator('Options:')
        opts.on('-t TARGET_DIR', '--target-dir TARGET_DIR', String,
                "Target directory for endpoint object models. Default: #{@params[:target_dir]}.") do |dir|
          @params[:target_dir] = dir
        end
        opts.on('-c COMPONENT', '--component COMPONENT', String,
                "Component name for endpoint classes. Default: #{@params[:component]}",
                'For a new project, a directory named like this will be created inside the target directory,',
                'and all the generated endpoint object models will be located inside.') do |component|
          @params[:component] = component
        end
        opts.on('--[no-]update-only', TrueClass,
                "Do not create new files, only update existing. Default: #{@params[:update_only]}") do |update_only|
          @params[:update_only] = update_only
        end
        opts.on('--[no-]rewrite-schemas', TrueClass,
                "Rewrite schema modules if they already exist. Default: #{@params[:rewrite_schemas]}") do |rewrite_schemas|
          @params[:rewrite_schemas] = rewrite_schemas
        end
        opts.on('--[no-]rewrite-classes', TrueClass,
                "Rewrite endpoint classes if they already exist. Default: #{@params[:rewrite_classes]}") do |rewrite_classes|
          @params[:rewrite_classes] = rewrite_classes
        end
        opts.on('--from-scratch', TrueClass,
                "Generate new testing framework. Will create a directory named 'harness' and generate",
                "the scaffold of the framework inside. Default: #{@params[:from_scratch]}") do |from_scratch|
          @params[:from_scratch] = from_scratch
        end
        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
    end

    def parse_cli_arguments(option_parser)
      begin
        option_parser.parse(@args)
      rescue OptionParser::ParseError => e
        raise Swgr2rbError, e.message
      end
      parse_url_from_args
    end

    def parse_url_from_args
      url = URI.extract(@args[0].to_s)&.first
      raise Swgr2rbError, 'Swagger URL is required' if url.nil?
      url
    end

    def format_target_dir_with_rubocop
      `rubocop -x #{File.join(@params[:target_dir], @params[:component])}`
    end
  end
end
