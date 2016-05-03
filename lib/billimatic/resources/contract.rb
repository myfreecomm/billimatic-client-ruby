module Billimatic
  module Resources
    class Contract < Base
      crud :all

      # TODO...
      # search

      def show(token:)
        http.get("#{resource_base_path}/token/#{token}") do |response|
          respond_with_entity(response)
        end
      end
    end
  end
end
