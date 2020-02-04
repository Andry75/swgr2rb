require_relative 'scaffold_generator_constants'

module Swgr2rb
  class FeatureFileGenerator
    def initialize(params)
      @params = params
      @filename = generate_filename
    end

    def generate_feature_file
      File.open(@filename, 'w') do |file|
        file.write(generate_lines.join("\n\n"))
      end
    end

    private

    def generate_filename
      File.join(ScaffoldGeneratorConstants::HARNESS_DIR,
                ScaffoldGeneratorConstants::FEATURES_DIR,
                @params[:component],
                ScaffoldGeneratorConstants::FEATURE_FILE_NAME)
    end

    def generate_lines
      [generate_tags,
       generate_feature_name,
       generate_scenario_name,
       generate_steps
      ].flatten.compact
    end

    def generate_tags
      ScaffoldGeneratorConstants::FF_TAGS.call(@params[:component])
    end

    def generate_feature_name
      ScaffoldGeneratorConstants::FF_NAME
    end

    def generate_scenario_name
      ScaffoldGeneratorConstants::FF_SCENARIO.call(example_endpoint)
    end

    def generate_steps
      ScaffoldGeneratorConstants::FF_STEPS.call(example_endpoint)
    end

    def example_endpoint
      @endpoint ||= Dir[File.join(@params[:target_dir], @params[:component], '*.rb')].sort.first
                        .split('/').last.sub('.rb', '')
                        .split('_').map(&:capitalize).join(' ')
    end
  end
end
