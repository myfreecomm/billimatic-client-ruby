require "base64"

module Billimatic
  class Configuration
    attr_accessor :url, :user_agent

    def initialize
      @url = "https://app.billimatic.com.br/api/v1"
      @user_agent = "Billimatic Ruby Client v#{Billimatic::VERSION}"
    end
  end
end
