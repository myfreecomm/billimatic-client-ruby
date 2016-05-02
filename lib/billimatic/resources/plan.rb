module Billimatic
  module Resources
    class Plan < Base
      def list(organization_id)
        http.get("/organizations/#{organization_id}#{resource_base_path}") do |response|
          respond_with_collection response
        end
      end
    end
  end
end
