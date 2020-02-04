require 'httparty'
require_relative 'response'

class ConductorSender
  class << self
    def send_request(request)
      response = send("send_#{request.type}_request",
                      request)

      Response.new(response)
    end

    private

    def send_post_request(request)
      HTTParty.post(request.url, body: request.body, headers: request.headers, verify: false)
    end

    def send_multipart_post_request(request)
      cmd = "curl -k -i --verbose --request POST "\
            " --form 'file=@#{request.body[:filePath]}'"\
            " -H 'Content-Type: #{request.headers[:'Content-Type']}'"\
            " -H 'Authorization: #{request.headers[:'Authorization']}'"\
            " #{request.url}"

      `#{cmd}`
    end

    def send_get_request(request)
      HTTParty.get(request.url, query: request.body, headers: request.headers, verify: false)
    end

    def send_put_request(request)
      HTTParty.put(request.url, body: request.body, headers: request.headers, verify: false)
    end

    def send_delete_request(request)
      HTTParty.delete(request.url, query: request.body, headers: request.headers, verify: false)
    end

    def send_head_request(request)
      HTTParty.head(request.url, query: request.body, headers: request.headers, verify: false)
    end

    def send_patch_request(request)
      HTTParty.patch(request.url, query: request.body, headers: request.headers, verify: false)
    end

    def send_options_request(request)
      HTTParty.options(request.url, query: request.body, headers: request.headers, verify: false)
    end
  end
end
