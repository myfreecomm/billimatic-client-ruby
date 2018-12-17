require 'typhoeus'
require 'multi_json'
require 'wisper'

require 'billimatic/version'
require 'billimatic/configuration'
require 'billimatic/client'
require 'billimatic/http'
require 'billimatic/signature'
require 'billimatic/url_helpers'

require 'billimatic/entities/base'
require 'billimatic/entities/service_item'
require 'billimatic/entities/entity_service_item'
require 'billimatic/entities/payment_information'
require 'billimatic/entities/product'
require 'billimatic/entities/service'
require 'billimatic/entities/receivable'
require 'billimatic/entities/plan_feature'
require 'billimatic/entities/plan'
require 'billimatic/entities/address_information'
require 'billimatic/entities/customer'
require 'billimatic/entities/company'
require 'billimatic/entities/person'
require 'billimatic/entities/organization'
require 'billimatic/entities/contract'
require 'billimatic/entities/invoice'
require 'billimatic/entities/invoice_rule'
require 'billimatic/entities/invoice_template'
require 'billimatic/entities/subscription'
require 'billimatic/entities/webhook'

require 'billimatic/resources/base'
require 'billimatic/resources/company'
require 'billimatic/resources/person'
require 'billimatic/resources/organization'
require 'billimatic/resources/contract'
require 'billimatic/resources/invoice_rule'
require 'billimatic/resources/invoice_template'
require 'billimatic/resources/invoice'
require 'billimatic/resources/plan'
require 'billimatic/resources/service_item'
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

  def self.url_helpers
    UrlHelpers.instance
  end
end
