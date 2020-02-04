module Swgr2rb
  class Swgr2rbError < RuntimeError
    def initialize(msg = nil)
      super("#{msg}\nTry 'swgr2rb --help' for more information")
    end
  end
end
