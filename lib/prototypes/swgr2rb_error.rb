# frozen_string_literal: true

module Swgr2rb
  # Swgr2rbError is a custom error that is raised when
  # an error occurs that requires a change in user input.
  # It is intercepted in bin/swgr2rb so that its backtrace
  # is not returned to the user.
  class Swgr2rbError < RuntimeError
    def initialize(msg = nil)
      super("#{msg}\nTry 'swgr2rb --help' for more information")
    end
  end
end
