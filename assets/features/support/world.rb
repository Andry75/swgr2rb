require_relative '../../endpoint_object_models/loader'
require_relative '../../request_sender/loader'
require_relative 'instance_variables'
require 'base64'

class World
  include InstanceVariables

  def initialize
    initialize_instance_variables
  end
end
