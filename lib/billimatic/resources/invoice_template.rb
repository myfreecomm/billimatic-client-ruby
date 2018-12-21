module Billimatic
  module Resources
    class InvoiceTemplate < Base
      def list(organization_id:)
        list_by_organization(organization_id)
      end

      def show(id, organization_id:)
        show_by_organization(organization_id, id)
      end
    end
  end
end
