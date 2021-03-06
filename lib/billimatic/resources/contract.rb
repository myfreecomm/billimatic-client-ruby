module Billimatic
  module Resources
    class Contract < Base
      crud :create, :update, :destroy

      def search(name:)
        http.get(
          "#{resource_base_path}/search", params: { name: name }
        ) { |response| respond_with_collection response }
      end

      def list(organization_id:)
        list_by_organization(organization_id)
      end

      def show(id, organization_id:)
        show_by_organization(organization_id, id)
      end
    end
  end
end
