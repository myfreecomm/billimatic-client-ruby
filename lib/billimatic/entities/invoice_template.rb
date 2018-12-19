module Billimatic
  module Entities
    class InvoiceTemplate < Base
      attribute :id, Integer
      attribute :name, String
      attribute :services, [Service]
      attribute :gross_value, Decimal
      attribute :month_quantity, Integer
      attribute :period_unit, String
      attribute :management_type, String
      attribute :automatic_email_template_id, Integer
      attribute :notification_ruler_id, Integer
      attribute :accrual_month_quantity, String
      attribute :description, String
      attribute :receivables_additional_information, Hash
      attribute :scheduled_updates, Hash
      attribute :notify_customer, Boolean
      attribute :apply_negative_updates, Boolean
      attribute :emites_service_values_id, Integer
      attribute :emites_service_value_name, String
      attribute :days_until_automatic_nfe_emission, Integer
      attribute :nfe_body, String
      attribute :payment_method, String
      attribute :cobrato_charge_config_id, Integer
      attribute :cobrato_charge_config_name, String
      attribute :cobrato_charge_template_id, Integer
      attribute :cobrato_charge_template_name, String
      attribute :finance_category, String
      attribute :finance_revenue_center, String
      attribute :myfinance_sale_account_id, Integer
      attribute :myfinance_sale_account_name, String
      attribute :created_at, DateTime
    end
  end
end
