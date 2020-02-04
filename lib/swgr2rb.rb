# frozen_string_literal: true
require 'optparse'
require_relative 'endpoint_class_generator/endpoint_classes_generator'

module Swgr2rb
  class Main
    def initialize(args)
      @args = args
    end

    def execute
      option_parser = generate_option_parser
      url, params = parse_cli_arguments(option_parser)
      if params[:from_scratch]
        raise 'Not implemented!'
      end
      EndpointClassesGenerator.new(url, params)
          .generate_endpoint_classes
      format_target_dir_with_rubocop
    end

    private

    def default_params
      @default_params ||= {
          target_dir: 'target',
          component: 'component',
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
        opts.separator("To generate new project from scratch:\n\t"\
                     "swgr2rb SWAGGER_URL --from-scratch [-t TARGET_DIR] [-c COMPONENT]\n"\
                     "To update existing project:\n\t"\
                     "swgr2rb SWAGGER_URL [-t TARGET_DIR] [-c COMPONENT] [--[no-]update-only] [--[no-]rewrite-schemas] [--[no-]rewrite-classes]")
        opts.separator('')
        opts.separator('Options description:')
        opts.on('-t TARGET_DIR', '--target-dir TARGET_DIR', String,
                "Target directory for endpoint object models. Default: #{default_params[:target_dir]}") do |dir|
          default_params[:target_dir] = dir
        end
        opts.on('-c COMPONENT', '--component COMPONENT', String,
                "Component name for endpoint classes. Default: #{default_params[:component]}") do |component|
          default_params[:component] = component
        end
        opts.on('--[no-]update-only', TrueClass,
                "Do not create new files, only update existing. Default: #{default_params[:update_only]}") do |update_only|
          default_params[:update_only] = update_only
        end
        opts.on('--[no-]rewrite-schemas', TrueClass,
                "Rewrite schema modules if they already exist. Default: #{default_params[:rewrite_schemas]}") do |rewrite_schemas|
          default_params[:rewrite_schemas] = rewrite_schemas
        end
        opts.on('--[no-]rewrite-classes', TrueClass,
                "Rewrite endpoint classes if they already exist. Default: #{default_params[:rewrite_classes]}") do |rewrite_classes|
          default_params[:rewrite_classes] = rewrite_classes
        end
        opts.on('--from-scratch', TrueClass,
                "Generate new project. Must be called from an empty directory. Default: #{default_params[:from_scratch]}") do |from_scratch|
          default_params[:from_scratch] = from_scratch
        end
        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
    end

    def parse_url_from_args
      url = URI.extract(@args[0].to_s)&.first
      if url.nil?
        raise ArgumentError, "Swagger URL is required"
      end
      url
    end

    def parse_cli_arguments(option_parser)
      begin
        option_parser.parse(@args)
        url = parse_url_from_args
      rescue OptionParser::ParseError, ArgumentError => e
        raise ArgumentError, "Invalid arguments! Pass --help option to see usage", cause: e
      end
      [url, default_params]
    end

    def format_target_dir_with_rubocop
      puts "Formatting generated files with rubocop..."
      `rubocop -x #{File.join(default_params[:target_dir], default_params[:component])}`
      puts "Formatting complete!"
    end
  end
end
