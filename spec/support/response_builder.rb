# frozen_string_literal: true

class ResponseBuilder
  attr_reader :json

  def initialize
    @json = {
      code: 200,
      headers: {},
      body: {
        swagger: {},
        info: {
          version: '1.0'
        },
        host: {},
        schemes: {}
      }
    }
  end

  def build_code(code)
    @json[:code] = code
    self
  end

  def build_headers(headers)
    @json[:headers] = headers
    self
  end

  def build_swagger(swagger_version)
    @json[:body][:swagger] = swagger_version.to_s
    self
  end

  def build_host(host)
    @json[:body][:host] = host.to_s
    self
  end

  def build_schemes(schemes)
    @json[:body][:schemes] = [schemes]
    self
  end

  def build_version(version)
    @json[:body][:info][:version] = version.to_s
    self
  end
end
