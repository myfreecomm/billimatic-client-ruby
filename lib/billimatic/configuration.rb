require "base64"

module Billimatic
  class Configuration
    attr_accessor :host, :url, :user_agent

    def initialize
      @host = "https://app.billimatic.com.br"
      @url = "#{@host}/api/v1"
      @user_agent = "Billimatic Ruby Client v#{Billimatic::VERSION}"
    end
  end
end
