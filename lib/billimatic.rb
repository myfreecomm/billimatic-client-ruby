require 'typhoeus'
require 'multi_json'
require 'wisper'

require 'billimatic/version'
require 'billimatic/configuration'
require 'billimatic/client'
require 'billimatic/http'
require 'billimatic/signature'

# require 'billimatic/entities/base'
# require 'billimatic/entities/payee'
# require 'billimatic/entities/bank_account'
# require 'billimatic/entities/charge_account'
# require 'billimatic/entities/charge'
# require 'billimatic/entities/webhook'
# require 'billimatic/entities/bank_billet'
# require 'billimatic/entities/regress_cnab'
# require 'billimatic/entities/remittance_cnab'

# require 'billimatic/resources/base'
# require 'billimatic/resources/payee'
# require 'billimatic/resources/bank_account'
# require 'billimatic/resources/charge_account'
# require 'billimatic/resources/charge'
# require 'billimatic/resources/webhook'
# require 'billimatic/resources/charging_type'
# require 'billimatic/resources/regress_cnab'
# require 'billimatic/resources/remittance_cnab'

module Billimatic
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.client(token)
    Client.new(token)
  end

  def self.subscribe(event, callback)
    Wisper.subscribe(callback, on: event, with: :call)
  end

  def self.signature(secret)
    Signature.new(secret)
  end
end
