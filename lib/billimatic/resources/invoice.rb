module Billimatic
  module Resources
    class Invoice < Base
      def search(contract_id:, issue_date_from:, issue_date_to:)
        http.get(
          "/contracts/#{contract_id}#{resource_base_path}/search",
          params: { issue_date_from: issue_date_from, issue_date_to: issue_date_to }
        ) do |response|
          respond_with_collection response
        end
      end

      def create(params, contract_id:)
        http.post(
          "/contracts/#{contract_id}#{resource_base_path}",
          body: { invoice: params }
        ) do |response|
          respond_with_entity(response)
        end
      end
    end
  end
end
