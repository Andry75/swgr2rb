class ResponseStub < Object
  attr_reader :response, :body, :headers

  def initialize(response_json)
    @response     = response_json
    @body         = response_json[:body]
    @headers      = response_json[:headers]
  end

  def code
    response[:code].to_i
  end

  def http_version
    response[:http_version]
  end

  def set_body(body)
    @body = body
  end

  def parsed_response
    response[:body]
  end

  def nil?
    response.nil? || response[:body].nil? || response[:body].empty?
  end
end
