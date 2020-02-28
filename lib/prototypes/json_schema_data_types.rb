# frozen_string_literal: true

module Swgr2rb
  # Boolean module is included in TrueClass and FalseClass
  # so that it can be used as a type when dealing with JSON schemas
  module Boolean; end
end
# rubocop:disable Style/Documentation
class TrueClass; include Swgr2rb::Boolean; end
class FalseClass; include Swgr2rb::Boolean; end
# rubocop:enable Style/Documentation
