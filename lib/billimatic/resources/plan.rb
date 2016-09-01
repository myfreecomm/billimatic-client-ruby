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
          "/organizations/#{organization_id}#{resource_base_path}",
          body: { plan: params }
        ) do |response|
          respond_with_entity(response)
        end
      end

      def update(id, params, organization_id:)
        http.put(
          "/organizations/#{organization_id}#{resource_base_path}/#{id}",
          body: { plan: params }
        ) do |response|
          respond_with_entity(response)
        end
      end

      def destroy(id, organization_id:)
        http.delete(
          "/organizations/#{organization_id}#{resource_base_path}/#{id}"
        ) do |response|
          response.code == 204
        end
      end
    end
  end
end
