module Billimatic
  module Resources
    class EmailTemplate < Base
      def list(organization_id:)
        list_by_organization(organization_id)
      end
    end
  end
end
