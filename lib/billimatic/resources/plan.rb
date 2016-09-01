module Billimatic
  module Resources
    class Plan < Base
      def list(organization_id:)
        http.get("/organizations/#{organization_id}#{resource_base_path}") do |response|
          respond_with_collection response
        end
      end

      def create(params, organization_id:)
        http.post(
          "/organizations/#{organization_id}/plans", { body: { plan: params } }
        ) do |response|
          respond_with_entity(response)
        end
      end
    end
  end
end
