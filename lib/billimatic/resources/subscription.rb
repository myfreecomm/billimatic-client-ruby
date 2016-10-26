module Billimatic
  module Resources
    class Subscription < Base
      crud :create

      def show(token:)
        http.get("#{resource_base_path}/token/#{token}") do |response|
          respond_with_entity(response)
        end
      end

      def checkout(params, token:)
        http.post(
          "#{resource_base_path}/checkout/#{token}", body: { subscription: params }
        ) do |response|
          respond_with_entity response
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

      def cancel(token:)
        http.patch("#{resource_base_path}/#{token}/cancel") do |response|
          respond_with_entity response
        end
      end

      def checkout_url(token:)
        "#{Billimatic.configuration.host}#{resource_base_path}/checkout/#{token}"
      end
    end
  end
end
