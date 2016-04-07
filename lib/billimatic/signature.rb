module Billimatic
  class Signature
    attr_accessor :secret

    def initialize(secret)
      @secret = secret
    end

    def check?(billimatic_request_id, signature_to_check, body)
      billimatic_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, "#{billimatic_request_id}#{body}")
      signature_to_check == billimatic_signature
    end
  end
end
