module Billimatic
  module Resources
    class Subscription < Base
      crud :create

      def show(token:)
        http.get("#{resource_base_path}/token/#{token}") do |response|
          respond_with_entity(response)
        end
      end

      def change_plan(token:, new_plan_id:)
        http.patch(
          "#{resource_base_path}/#{token}/change_plan",
          body: { subscription: { new_plan_id: new_plan_id } }
        ) do |response|
          respond_with_entity response
        end
      end

      def cancel(token:, cancel_date: nil, cancel_reason: nil)
        http.patch(
          "#{resource_base_path}/#{token}/cancel",
          body: { subscription: { cancel_date: cancel_date, cancel_reason: cancel_reason } }
        ) do |response|
          respond_with_entity response
        end
      end

      def checkout_url(token:)
        "#{Billimatic.configuration.host}#{resource_base_path}/checkout/#{token}"
      end
    end
  end
end
