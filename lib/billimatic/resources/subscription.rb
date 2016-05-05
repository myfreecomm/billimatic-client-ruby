module Billimatic
  module Resources
    class Subscription < Base
      crud :create

      def show(token:)
        http.get("#{resource_base_path}/token/#{token}") do |response|
          respond_with_entity(response)
        end
      end

      def cancel(token:)
        http.patch("#{resource_base_path}/#{token}/cancel") do |response|
          respond_with_entity response
        end
      end
    end
  end
end
