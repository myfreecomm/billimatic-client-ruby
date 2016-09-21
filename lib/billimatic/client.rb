module Billimatic
  class Client
    attr_reader :http

    def initialize(token)
      @http = Http.new(token)
    end

    def authenticated?
      http.get("/companies/search?cnpj=auth_test") do |response|
        response.code == 200
      end
    rescue RequestError => e
      raise e unless e.code == 401
      false
    end

    def plans
      Resources::Plan.new(http)
    end

    def subscriptions
      Resources::Subscription.new(http)
    end

    def contracts
      Resources::Contract.new(http)
    end

    def invoices
      Resources::Invoice.new(http)
    end

    def invoice_rules
      Resources::InvoiceRule.new(http)
    end

    def companies
      Resources::Company.new(http)
    end

    def organizations
      Resources::Organization.new(http)
    end

    def service_items
      Resources::ServiceItem.new(http)
    end

    def webhooks
      Resources::Webhook.new(http)
    end
  end
end
