# frozen_string_literal: true

module Swgr2rb
  # Response parses API response.
  class Response
    attr_accessor :code, :headers, :body

    def initialize(response)
      @response = response
      check_response
    end

    private

    def check_response
      if @response.is_a?(String)
        return if try_to_parse_json_from_string
      end

      if @response.nil? || (@response.respond_to?(:body) &&
          %w[null true false].include?(@response.body))
        handle_nil_response
      else
        handle_response
      end
    end

    def try_to_parse_json_from_string
      resp_hash = JSON.parse(@response)
      return unless resp_hash

      @code = 200
      @headers = ''
      @body = convert_hash(resp_hash)
    rescue StandardError
      raise Swgr2rbError,
            'An error occurred while trying to parse JSON from API response'
    end

    def convert_hash(base_hash)
      return base_hash unless base_hash.is_a? Hash

      temp_hash = base_hash.dup
      base_hash.each do |k, v|
        temp_hash = convert_key_value_pair(temp_hash, k, v)
      end
      temp_hash
    end

    def convert_key_value_pair(dest, key, value)
      case value
      when Hash
        dest[key.to_sym] = convert_hash(value)
      when Array
        dest[key.to_sym] = value.map { |v| convert_hash(v) }
      else
        dest = dest.transform_keys(&:to_sym)
      end
      dest
    end

    def handle_nil_response
      @code = @response.code
      @headers = @response.headers

      if @code == 204
        unless @response.body.nil?
          raise 'Received non-null body in 204 No Content response'
        end

        @body = nil
      else
        parse_body_for_nil_response
      end
    end

    def parse_body_for_nil_response
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

    def handle_response
      @code = @response.code
      @headers = @response.headers
      @body = parse_response_body
    end

    def parse_response_body
      if @headers&.content_type == 'application/json'
        parse_json_body
      else
        # parsed response is string
        @response.parsed_response
      end
    end

    def parse_json_body
      if @response.parsed_response.is_a? Array
        @response.parsed_response.map { |i| convert_hash(i) }
      elsif @response.parsed_response.is_a? Integer
        @response.parsed_response
      else
        convert_hash(@response.parsed_response)
      end
    end
  end
end
