module Billimatic
  module Resources
    class Organization < Base
      def search(cnpj:)
        http.get("#{resource_base_path}/search", params: {cnpj: cnpj}) do |response|
          respond_with_entity(response)
        end
      end
    end
  end
end
