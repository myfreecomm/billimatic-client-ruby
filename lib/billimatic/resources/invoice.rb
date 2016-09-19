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
    end
  end
end
