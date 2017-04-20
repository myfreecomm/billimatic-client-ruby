module Billimatic
  module Entities
    class Invoice < Base
      attribute :id, Integer
      attribute :contract_id, Integer
      attribute :issue_date, Date
      attribute :gross_value, Decimal
      attribute :payment_value, Decimal
      attribute :description, String
      attribute :state, String
      attribute :nfe_service, String
      attribute :nfe_verification, String
      attribute :nfe_issue_date, DateTime
      attribute :nfe_body, String
      attribute :nfe_issued, Boolean
      attribute :number, String
      attribute :created_at, DateTime
      attribute :accrual_date, Date
      attribute :comments, String
      attribute :customer_id, Integer
      attribute :customer_type, String
      attribute :emites_service_values_id, Integer
      attribute :emites_service_value_name, String
      attribute :finance_category, String
      attribute :finance_revenue_center, String
      attribute :finance_receive_via, String
      attribute :cobrato_charge_config_id, Integer
      attribute :cobrato_charge_config_name, String
      attribute :cobrato_charge_template_id, Integer
      attribute :cobrato_charge_template_name, String
      attribute :management_type, String
      attribute :days_until_automatic_nfe_emission, Integer
      attribute :automatic_nfe_issue_date, Date
      attribute :automatic_email_template_id, Integer
      attribute :receivables, [Receivable]
      attribute :services, [Service]
      attribute :attachments, [Hash]
    end
  end
end
