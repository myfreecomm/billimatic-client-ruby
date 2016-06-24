require "base64"

module Billimatic
  class Configuration
    attr_accessor :host, :user_agent

    def initialize
      @host = "https://app.billimatic.com.br"
      @user_agent = "Billimatic Ruby Client v#{Billimatic::VERSION}"
    end

    def url
      "#{self.host}/api/v1"
    end
  end
end
