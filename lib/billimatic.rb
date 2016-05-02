require 'typhoeus'
require 'multi_json'
require 'wisper'

require 'billimatic/version'
require 'billimatic/configuration'
require 'billimatic/client'
require 'billimatic/http'
require 'billimatic/signature'

require 'billimatic/entities/base'
require 'billimatic/entities/address_information'
require 'billimatic/entities/customer'
require 'billimatic/entities/company'
require 'billimatic/entities/contract'
require 'billimatic/entities/invoice'
require 'billimatic/entities/invoice_rule'
require 'billimatic/entities/entity_service_item'
require 'billimatic/entities/plan'
require 'billimatic/entities/subscription'
require 'billimatic/entities/webhook'

require 'billimatic/resources/base'
require 'billimatic/resources/company'
require 'billimatic/resources/contract'
require 'billimatic/resources/invoice'
require 'billimatic/resources/invoice_rule'
require 'billimatic/resources/plan'
require 'billimatic/resources/subscription'
require 'billimatic/resources/webhook'

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
