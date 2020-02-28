# frozen_string_literal: true

require 'rspec'
require 'swgr2rb'
require 'fileutils'

RSpec.describe Swgr2rb, :integration do
  let(:json_filename) { 'test.json' }
  before(:each) { Dir.mkdir('tmp') }
  after(:each) { FileUtils.rm_r('tmp') }

  context 'when generating new testing framework' do
    it 'works correctly when called with --component' do
      endpoints = IntegrationConstants::ENDPOINT_MODEL_STUBS.keys
      create_swagger_json_file(endpoints, File.join('tmp', json_filename))
      component = 'new_component'

      swgr2rb("#{json_filename} --from-scratch -c #{component}")

      expect(actual_generated_filenames)
        .to eq(expected_generated_filenames(component, endpoints))

      generated_endpoint_files(endpoints, component).each do |filename|
        expect(File.read(generated_endpoint_filepath(filename)))
          .to eq(File.read(expected_endpoint_filepath(filename)))
      end
    end

    it 'exits when harness directory already exists and is not empty' do
      create_swagger_json_file(%i[create_user], File.join('tmp', json_filename))
      Dir.mkdir('tmp/harness')
      File.open('tmp/harness/file.txt', 'w') { |file| file.write('Hello world') }
      pre_run_filenames = all_filenames_recursive('tmp/harness')

      expect { swgr2rb("#{json_filename} --from-scratch") }
        .to raise_error(Swgr2rb::Swgr2rbError,
                        /harness directory already exists and is not empty/)
      expect(all_filenames_recursive('tmp/harness'))
        .to eq(pre_run_filenames)
    end
  end

  context 'when updating existing testing framework' do
    it 'generates new endpoint models and updates existing schemas' do
      # setup testing framework to update
      endpoints = %i[create_user delete_record get_all_records]
      component = 'meow'
      create_swagger_json_file(endpoints, File.join('tmp', json_filename))
      swgr2rb("#{json_filename} --from-scratch --component #{component}")

      # update testing framework with new endpoints
      endpoints += %i[get_all_users upload_user_key update_record]
      create_swagger_json_file(endpoints, File.join('tmp', json_filename))
      swgr2rb("#{json_filename} --target-dir harness/endpoint_object_models/object_models -c #{component}")

      expect(actual_generated_filenames)
        .to eq(expected_generated_filenames(component, endpoints))

      generated_endpoint_files(endpoints, component).each do |filename|
        expect(File.read(generated_endpoint_filepath(filename)))
          .to eq(File.read(expected_endpoint_filepath(filename)))
      end
    end

    it 'updates existing schemas and does not generate new files when called with --update-only' do
      # setup testing framework to update
      old_endpoints = %i[create_user upload_user_key get_all_users get_all_records]
      component = 'meow'
      create_swagger_json_file(old_endpoints, File.join('tmp', json_filename))
      swgr2rb("#{json_filename} --from-scratch --component #{component}")
      files_after_1st_execution = actual_generated_filenames

      # modify one of the schemas
      schema_file = File.join('tmp', 'harness',
                              IntegrationConstants::EXPECTED_SCHEMA_FILENAME.call(old_endpoints.first, component))
      File.open(schema_file, 'w') do |file|
        file.write('Random Content!')
      end

      # update testing framework
      endpoints = old_endpoints + %i[update_record delete_record]
      create_swagger_json_file(endpoints, File.join('tmp', json_filename))
      swgr2rb("#{json_filename} --update-only -t harness/endpoint_object_models/object_models -c #{component}")

      expect(actual_generated_filenames)
        .to eq(files_after_1st_execution)

      generated_endpoint_files(old_endpoints, component).each do |filename|
        expect(File.read(generated_endpoint_filepath(filename)))
          .to eq(File.read(expected_endpoint_filepath(filename)))
      end
    end

    it 'generates new files and does not update existing schemas when called with --no-rewrite-schemas' do
      # setup testing framework to update
      old_endpoints = %i[create_user get_all_users]
      component = 'meow'
      create_swagger_json_file(old_endpoints, File.join('tmp', json_filename))
      swgr2rb("#{json_filename} --from-scratch --component #{component}")
      files_after_1st_execution = actual_generated_filenames

      # modify one of the schemas
      schema_file = File.join('tmp', 'harness',
                              IntegrationConstants::EXPECTED_SCHEMA_FILENAME.call(old_endpoints.first, component))
      modified_content = "Random Content!\n"
      File.open(schema_file, 'w') do |file|
        file.write(modified_content)
      end

      # update testing framework
      endpoints = old_endpoints + %i[upload_user_key get_all_records update_record delete_record]
      create_swagger_json_file(endpoints, File.join('tmp', json_filename))
      swgr2rb("#{json_filename} --no-rewrite-schemas -t harness/endpoint_object_models/object_models -c #{component}")

      expect(actual_generated_filenames)
        .not_to eq(files_after_1st_execution)
      expect(actual_generated_filenames)
        .to eq(expected_generated_filenames(component, endpoints))

      generated_endpoint_files(endpoints, component).each do |filename|
        if generated_endpoint_filepath(filename) == schema_file
          expect(File.read(generated_endpoint_filepath(filename)))
            .to eq(modified_content)
        else
          expect(File.read(generated_endpoint_filepath(filename)))
            .to eq(File.read(expected_endpoint_filepath(filename)))
        end
      end
    end
  end

  context 'when handling invalid input' do
    it 'exits when called with invalid swagger url/filepath' do
      expect { swgr2rb('') }.to raise_error(Swgr2rb::Swgr2rbError)
      expect { swgr2rb('non-existing.json') }.to raise_error(Swgr2rb::Swgr2rbError)
      expect(all_filenames_recursive('tmp')).to be_empty
    end

    it 'exits when called with invalid options' do
      create_swagger_json_file(%i[create_user], File.join('tmp', json_filename))

      expect { swgr2rb("#{json_filename} -t") }.to raise_error(Swgr2rb::Swgr2rbError)
      expect { swgr2rb("#{json_filename} -c") }.to raise_error(Swgr2rb::Swgr2rbError)
      expect { swgr2rb("#{json_filename} --non-existing") }.to raise_error(Swgr2rb::Swgr2rbError)

      expect(all_filenames_recursive('tmp')).to eq([json_filename])
    end
  end

  it 'exits when called with --help option' do
    expect { swgr2rb('--help') }.to raise_error(SystemExit)
    expect { swgr2rb('-h') }.to raise_error(SystemExit)
    expect(all_filenames_recursive('tmp')).to be_empty
  end
end
