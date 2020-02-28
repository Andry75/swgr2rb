# frozen_string_literal: true

require_relative 'cli/cli_options_parser'
require_relative 'endpoint_class_generator/endpoint_classes_generator'
require_relative 'scaffold_generator/scaffold_generator'
require_relative 'scaffold_generator/scaffold_generator_constants'

module Swgr2rb
  # Main is being called from bin/swgr2rb.
  class Main
    def initialize(args)
      @args = args
    end

    def execute
      @url, @params = parse_cli_arguments
      generate_scaffold if @params[:from_scratch]
      generate_endpoint_object_models
      generate_example_feature_file if @params[:from_scratch]
      format_target_dir_with_rubocop
    end

    private

    def parse_cli_arguments
      CliOptionsParser.new.parse(@args)
    end

    def generate_scaffold
      @params.merge!(target_dir: File.join(ScaffoldGeneratorConstants::HARNESS_DIR,
                                           ScaffoldGeneratorConstants::ENDPOINT_MODELS_DIR),
                     update_only: false)
      puts 'Generating scaffold of the testing framework...'
      ScaffoldGenerator.generate_scaffold
    end

    def generate_endpoint_object_models
      puts "Generating endpoint classes in #{@params[:target_dir]}..."
      EndpointClassesGenerator.new(@url, @params).generate_endpoint_classes
    end

    def generate_example_feature_file
      puts 'Generating example feature file...'
      ScaffoldGenerator.generate_example_feature_file(@params)
    end

    def format_target_dir_with_rubocop
      puts 'Formatting generated endpoint object models with rubocop...'
      `rubocop -x #{File.join(@params[:target_dir], @params[:component])}`
      puts 'Done!'
    end
  end
end
