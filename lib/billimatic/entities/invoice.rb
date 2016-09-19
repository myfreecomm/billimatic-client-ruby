module Billimatic
  module Entities
    class Invoice < Base
      attribute :id, Integer
      attribute :contract_id, Integer
      attribute :gross_value, Decimal
      attribute :number, String
      attribute :issue_date, Date
      attribute :state, Integer
      attribute :description, String
      attribute :nfe_service, String
      attribute :nfe_verification, String
      attribute :created_at, DateTime
      attribute :payment_value, Decimal
      attribute :emites_service_values_id, Integer
      attribute :finance_category, String
      attribute :finance_revenue_center, String
      attribute :finance_receive_via, String
      attribute :nfe_issued, Boolean
      attribute :nfe_issue_date, DateTime
      attribute :cobrato_charge_config_id, Integer
      attribute :services, [Service]
      attribute :attachments, [Hash]
    end
  end
end
