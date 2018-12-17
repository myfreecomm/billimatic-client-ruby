require 'spec_helper'

describe Billimatic::Entities::InvoiceTemplate do
  let(:attributes) do
    {
      id: 1,
      name: 'Template',
      gross_value: 123,
      month_quantity: 2,
      period_unit: 'monthly',
      management_type: 'manual'
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :name, :services, :gross_value, :month_quantity, :period_unit,
                    :management_type, :automatic_email_template_id,
                    :notification_ruler_id, :accrual_month_quantity, :description,
                    :receivables_additional_information, :emites_service_values_id,
                    :emites_service_value_name, :days_until_automatic_nfe_emission,
                    :nfe_body, :payment_method, :cobrato_charge_config_id,
                    :cobrato_charge_config_name, :cobrato_charge_template_id,
                    :cobrato_charge_template_name, :finance_category, :finance_revenue_center,
                    :myfinance_sale_account_id, :myfinance_sale_account_name, :created_at
                  ]
end
