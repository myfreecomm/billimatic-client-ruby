module Billimatic
  module Resources
    class Contract < Base
      crud :create, :update, :destroy

      def search(name:)
        http.get(
          "#{resource_base_path}/search", params: { name: name }
        ) do |response|
          respond_with_collection response
        end
      end

      def list(organization_id:)
        list_by_organization(organization_id)
      end
    end
  end
end
