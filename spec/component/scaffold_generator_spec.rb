# frozen_string_literal: true

require 'rspec'
require 'swgr2rb'
require 'fileutils'

RSpec.describe Swgr2rb::ScaffoldGenerator do
  let(:target_dir) { 'spec/target_dir' }
  after(:each) { FileUtils.rm_r(target_dir) }

  context 'when generating scaffold' do
    it 'works correctly when harness directory does not exist' do
      FileUtils.mkdir_p(target_dir)
      Dir.chdir(target_dir) do
        Swgr2rb::ScaffoldGenerator.generate_scaffold
      end
      generated_files = Dir.glob(File.join(target_dir, 'harness/**/*'))
                           .map { |filename| filename.sub(%r{^#{target_dir}/harness/}, '') }
      source_files = Dir.glob('assets/**/*').map { |filename| filename.sub(%r{^assets/}, '') }
      expect(generated_files).to eq(source_files)
    end

    it 'works correctly when harness directory already exists but is empty' do
      FileUtils.mkdir_p(File.join(target_dir, 'harness'))
      Dir.chdir(target_dir) do
        Swgr2rb::ScaffoldGenerator.generate_scaffold
      end
      generated_files = Dir.glob(File.join(target_dir, 'harness/**/*'))
                           .map { |filename| filename.sub(%r{^#{target_dir}/harness/}, '') }
      source_files = Dir.glob('assets/**/*').map { |filename| filename.sub(%r{^assets/}, '') }
      expect(generated_files).to eq(source_files)
    end

    it 'raises error when harness directory already exists and is not empty' do
      FileUtils.mkdir_p(File.join(target_dir, 'harness', 'something_else'))
      Dir.chdir(target_dir) do
        expect { Swgr2rb::ScaffoldGenerator.generate_scaffold }
          .to raise_error(Swgr2rb::Swgr2rbError,
                          /harness directory already exists and is not empty/)
      end
    end
  end

  context 'when generating a feature file' do
    it 'creates a component directory for an example feature file' do
      component = 'amazing_component'

      # create directory for feature files
      feature_files_dir = File.join(target_dir, 'harness', 'features')
      FileUtils.mkdir_p(feature_files_dir)

      ff_generator = double('feature file generator', generate_feature_file: nil)
      allow(Swgr2rb::FeatureFileGenerator).to receive(:new).and_return(ff_generator)

      Dir.chdir(target_dir) do
        Swgr2rb::ScaffoldGenerator
          .generate_example_feature_file(component: component)
      end

      created_dir = File.join(feature_files_dir, 'component', component)
      expect(File.exist?(created_dir)).to be(true)
      expect(File.directory?(created_dir)).to be(true)
    end
  end
end
