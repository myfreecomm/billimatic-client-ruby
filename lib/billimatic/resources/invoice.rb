module Billimatic
  module Resources
    class Invoice < InvoiceRule
      def search(contract_id:, issue_date_from:, issue_date_to:)
        http.get(
          "/contracts/#{contract_id}#{resource_base_path}/search",
          params: { issue_date_from: issue_date_from, issue_date_to: issue_date_to }
        ) do |response|
          respond_with_collection response
        end
      end

      def late(contract_id:)
        http.get("/contracts/#{contract_id}#{resource_base_path}/late") do |response|
          respond_with_collection response
        end
      end

      def show(id, contract_id:)
        http.get(
          "/contracts/#{contract_id}#{resource_base_path}/#{id}"
        ) do |response|
          respond_with_entity response
        end
      end

      def destroy(id, contract_id:)
        http.delete(
          "/contracts/#{contract_id}#{resource_base_path}/#{id}"
        ) do |response|
          response.code == 204
        end
      end

      def block(id, contract_id:)
        http.patch(
          "/contracts/#{contract_id}/invoices/#{id}/block"
        ) do |response|
          respond_with_entity response
        end
      end

      def approve(id, contract_id:)
        http.patch(
          "/contracts/#{contract_id}/invoices/#{id}/approve"
        ) do |response|
          respond_with_entity response
        end
      end
    end
  end
end
