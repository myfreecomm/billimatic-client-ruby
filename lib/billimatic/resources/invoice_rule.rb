module Billimatic
  module Resources
    class InvoiceRule < Base
      def list(contract_id:)
        http.get(
          "/contracts/#{contract_id}#{resource_base_path}"
        ) { |response| respond_with_collection(response) }
      end

      def create(params, contract_id:)
        http.post(
          "/contracts/#{contract_id}#{resource_base_path}",
          body: { underscored_klass_name.to_sym => params }
        ) { |response| respond_with_entity(response) }
      end

      def update(id, params, contract_id:)
        http.put(
          "/contracts/#{contract_id}#{resource_base_path}/#{id}",
          body: { underscored_klass_name.to_sym => params }
        ) { |response| respond_with_entity(response) }
      end

      def destroy(id, contract_id:)
        http.delete(
          "/contracts/#{contract_id}#{resource_base_path}/#{id}"
        ) { |response| response.code == 204 }
      end
    end
  end
end
