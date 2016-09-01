require 'spec_helper'

describe Billimatic::Entities::InvoiceRule do
  let(:attributes) do
    {
      id: 1,
      gross_value: 100.0,
      description: 'Faturamento',
      nfe_body: 'Corpo do faturamento',
      charge_type: 'fixed_day',
      customer_id: 1,
      customer_type: 'Company',
      emites_service_values_id: 1,
      emites_service_value_name: 'service',
      finance_category: 'categoria',
      finance_revenue_center: 'c1',
      finance_receive_via: 'bank',
      cobrato_charge_config_id: 1,
      cobrato_charge_config_name: 'charge',
      additional_information: {
        id: 1,
        init_date: '09-01-2016',
        month_quantity: 12,
        end_date: '09-01-2017',
        accrual_month_quantity: 1
      },
      scheduled_update: {
        id: 1,
        init_date: '10-01-2016',
        month_quantity: 12,
        price_index: 'ipca',
        days_until_update: 5,
        _destroy: false
      },
      receivables_additional_information: {
        id: 1,
        parcel_number: 2,
        day_number: 5,
        month_quantity: 12,
        day_quantity: 0
      }
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :gross_value, :description, :nfe_body, :charge_type,
                    :customer_id, :customer_type, :emites_service_values_id,
                    :emites_service_value_name, :finance_category,
                    :finance_revenue_center, :finance_receive_via,
                    :cobrato_charge_config_id, :cobrato_charge_config_name,
                    :additional_information, :scheduled_update,
                    :receivables_additional_information
                  ]
end
