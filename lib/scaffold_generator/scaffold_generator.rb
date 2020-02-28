# frozen_string_literal: true

require 'fileutils'
require_relative 'feature_file_generator'
require_relative 'scaffold_generator_constants'
require_relative '../prototypes/swgr2rb_error'

module Swgr2rb
  # ScaffoldGenerator generates a scaffold of a testing framework.
  class ScaffoldGenerator
    include ScaffoldGeneratorConstants

    class << self
      def generate_scaffold
        create_harness_dir
        copy_scaffold
      end

      def generate_example_feature_file(params)
        create_features_component_dir(params)
        FeatureFileGenerator.new(params).generate_feature_file
      end

      private

      def create_harness_dir
        if Dir.exist?(ScaffoldGeneratorConstants::HARNESS_DIR)
          unless Dir.empty?(ScaffoldGeneratorConstants::HARNESS_DIR)
            raise Swgr2rbError,
                  'harness directory already exists and is not empty'
          end
        else
          Dir.mkdir(ScaffoldGeneratorConstants::HARNESS_DIR)
        end
      end

      def copy_scaffold
        FileUtils.cp_r(File.join(File.dirname(__FILE__),
                                 ScaffoldGeneratorConstants::PATH_TO_ASSETS,
                                 '.'),
                       ScaffoldGeneratorConstants::HARNESS_DIR)
      end

      def create_features_component_dir(params)
        FileUtils.mkdir_p(File.join(ScaffoldGeneratorConstants::HARNESS_DIR,
                                    ScaffoldGeneratorConstants::FEATURES_DIR,
                                    params[:component]))
      end
    end
  end
end
