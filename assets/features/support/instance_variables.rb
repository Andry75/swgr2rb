module InstanceVariables
  attr_accessor :endpoint_instances

  def initialize_instance_variables
    @endpoint_instances = {}
    @db_query_results = {}
    @broker_results = {}
  end
end
