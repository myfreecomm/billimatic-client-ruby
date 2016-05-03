module Billimatic
  module Resources
    class Subscription < Base
      crud :create

      def cancel(token:)
        http.patch("#{resource_base_path}/#{token}/cancel") do |response|
          respond_with_entity response
        end
      end
    end
  end
end
