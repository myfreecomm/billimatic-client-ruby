module Billimatic
  module Entities
    class InvoiceRule < Base
      attribute :id, Integer
      attribute :gross_value, Decimal
      attribute :description, String
      attribute :nfe_body, String
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
      attribute :services, Array[Service]
      attribute :additional_information, Hash
      attribute :scheduled_update, Hash
      attribute :receivables_additional_information, Hash
    end
  end
end
