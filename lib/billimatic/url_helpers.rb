module Billimatic
  class UrlHelpers
    include Singleton

    def checkout_url(token:)
      "#{Billimatic.configuration.host}/subscriptions/checkout/#{token}"
    end

    def subscription_dashboard_url(token:)
      "#{Billimatic.configuration.host}/subscriptions/#{token}/dashboard"
    end

    def change_plan_url(token:, plan_id:)
      "#{Billimatic.configuration.host}/subscriptions/#{token}/change_plan/#{plan_id}"
    end
  end
end
