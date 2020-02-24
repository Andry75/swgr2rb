require 'rspec'
require 'swgr2rb'

RSpec.describe Swgr2rb::Main do
  context'when parsing options' do
    it 'exists with an error message when URL is not passed' do
      args = ['test']
      main = Swgr2rb::Main.new(args)
      error = Swgr2rb::Swgr2rbError.new('Swagger URL is required')

      expect { main.execute.message }.to raise_error(error.message)
    end
  end
end
