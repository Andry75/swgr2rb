# frozen_string_literal: true

class HeadersStub < Object
  attr_reader :content_type

  def initialize(content_type)
    @content_type = content_type
  end
end
