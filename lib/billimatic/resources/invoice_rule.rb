module Billimatic
  module Resources
    class InvoiceRule < Base
      def create(params, contract_id:)
        http.post(
          "/contracts/#{contract_id}#{resource_base_path}",
          body: { invoice_rule: params }
        ) do |response|
          respond_with_entity(response)
        end
      end

      def update(id, params, contract_id:)
        http.put(
          "/contracts/#{contract_id}#{resource_base_path}/#{id}",
          body: { invoice_rule: params }
        ) do |response|
          respond_with_entity(response)
        end
      end
    end
  end
end
