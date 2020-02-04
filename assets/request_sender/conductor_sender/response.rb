class Response
  attr_accessor :code, :headers, :body

  def initialize(response)
    @response = response
    check_response
  end

  private

  def check_response
    case @response
    when String
      begin
        hash_ = JSON.parse(@response)
        if hash_
          @code = 200
          @headers = ''
          @body = convert_hash(hash_)
          return
        end
      rescue
      end
    end

    if @response.nil? || (@response.respond_to?(:body) && %w[null true false].include?(@response.body))
      handle_nil_response
    else
      handle_response
    end
  end

  def convert_hash(base_hash)
    return base_hash unless base_hash.is_a? Hash
    temp_hash = base_hash.dup
    base_hash.each do |k, v|
      case v
      when Hash
        temp_hash[k.to_sym] = convert_hash(v)
      when Array
        temp_hash[k.to_sym] = v.map { |v_el| convert_hash(v_el) }
      else
        temp_hash = temp_hash.inject({}) { |memo, (k1, v1)| memo[k1.to_sym] = v1; memo }
      end
    end
    temp_hash
  end

  def handle_nil_response
    @code = @response.code
    @headers = @response.headers

    if @code == 204
      raise 'Received non-null body in 204 No Content response' unless @response.body.nil?
      @body = nil
    else
      case @response.body
      when 'null', ''
        @body = {}
      when 'true'
        @body = true
      when 'false'
        @body = false
      else
        raise 'Not implemented behavior for the empty response'
      end
    end
  end

  def handle_response
    case @response
    when String
      @code = (@response.match /(HTTP Status|HTTP\/2) \d{3}/).to_s.split(' ')[-1].to_i
      content_type = if @response.match?(/content-type: (.*);/)
                       @response.match(/content-type: (.*);/)[1]
                     else
                       'text/html'
                     end
      @headers = {
          "ContentType": content_type
      }
      @body = if @response.match?(/{.*}/)
                convert_hash(JSON.parse(@response.match(/{.*}/)[0]))
              else
                @response
              end
      return
    else
      @code = @response.code
      @headers = @response.headers
    end
    if @headers&.content_type == 'application/json'
      @body = if @response.parsed_response.is_a? Array
                @response.parsed_response.map { |i| convert_hash(i)}
              elsif @response.parsed_response.is_a? Integer
                @response.parsed_response
              else
                convert_hash(@response.parsed_response)
              end
    else
      # parsed response is string
      @body = @response.parsed_response
    end
  end
end
