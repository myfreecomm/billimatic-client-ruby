module Billimatic
  module Resources
    class Company < Base
      crud :create, :destroy

      def initialize(http)
        @collection_name = 'companies'
        super(http)
      end

      # GET /api/v1/companies/search
      def search(cnpj)
        http.get("#{resource_base_path}/search", params: {cnpj: cnpj}) do |response|
          respond_with_collection(response)
        end
      end

      # PATCH /api/v1/companies/:id
      def update(id, params)
        http.patch("#{resource_base_path}/#{id}", body: params) do |response|
          respond_with_entity(response)
        end
      end
    end
  end
end
