# frozen_string_literal: true

require 'rspec'
require 'swgr2rb'
require 'fileutils'

RSpec.describe Swgr2rb::RubyFileGenerator do
  context 'when generating ruby file' do
    let(:ruby_file_generator) do
      Class.new(Swgr2rb::RubyFileGenerator) do
        def initialize(opts, content = '')
          @mock_content = content
          super(nil, opts)
        end

        def generate_lines
          @mock_content.split("\n")
        end
      end
    end

    before(:each) { Dir.mkdir('tmp') }
    after(:each) { FileUtils.rm_r('tmp') }

    it 'creates new file when update_only is set to false' do
      ruby_file_generator.new({ name: 'TestRubyFileGenerator',
                                target_dir: 'tmp',
                                update_only: false })
                         .generate_file
      expect(File.exist?('tmp/test_ruby_file_generator.rb')).to be(true)
    end

    it 'does not create new file when update_only is set to true' do
      ruby_file_generator.new({ name: 'TestRubyFileGenerator',
                                target_dir: 'tmp',
                                update_only: true })
                         .generate_file
      expect(File.exist?('tmp/test_ruby_file_generator.rb')).to be(false)
    end

    it 'does not change existing file content when rewrite is set to false' do
      filename = 'tmp/test_ruby_file_generator.rb'
      file_content = "class TestRubyFileGenerator\nend"
      File.open(filename, 'w') { |file| file.write(file_content) }
      ruby_file_generator.new({ name: 'TestRubyFileGenerator',
                                target_dir: 'tmp',
                                rewrite: false },
                              'New Content!')
                         .generate_file
      expect(File.read(filename)).to eq(file_content)
    end

    it 'rewrites existing file when rewrite is set to true' do
      filename = 'tmp/test_ruby_file_generator.rb'
      new_content = 'New Content!'
      File.open(filename, 'w') do |file|
        file.write("class TestRubyFileGenerator\nend")
      end
      ruby_file_generator.new({ name: 'TestRubyFileGenerator',
                                target_dir: 'tmp',
                                rewrite: true },
                              new_content)
                         .generate_file
      expect(File.read(filename)).to eq(new_content)
    end

    it 'creates target_dir if it does not exist' do
      target_dir = 'tmp/test_ruby_file_generator'
      ruby_file_generator.new({ name: 'TestRubyFileGenerator',
                                target_dir: target_dir,
                                update_only: false },
                              "class TestRubyFileGenerator\nend")
                         .generate_file
      expect(File.exist?(target_dir) && File.directory?(target_dir)).to be(true)
    end
  end
end
