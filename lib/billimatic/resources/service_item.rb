module Billimatic
  module Resources
    class ServiceItem < Base
      crud :list, :create, :update, :destroy

      def search(name:)
        http.get(
          "#{resource_base_path}/search", params: { name: name }
        ) do |response|
          respond_with_entity response
        end
      end
    end
  end
end
