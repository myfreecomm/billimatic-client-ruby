module Billimatic
  module Resources
    class Company < Base

      # GET /api/v1/companies/search
      def search(cnpj)
        http.get("/companies/search", params: {cnpj: cnpj}) do |response|
          respond_with_collection(response)
        end
      end

    end
  end
end
