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
        period_unit: 0,
        month_quantity: 12,
        end_date: '09-01-2017',
        accrual_month_quantity: 1
      },
      services: [
          Billimatic::Entities::Service.new(
          id: 1,
          service_item_id: 1,
          description: 'Descrição do serviço',
          units: 2,
          unit_value: 200.0,
          value: 400.0
        )
      ],
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
      },
      payment_information: {
        id: 1234,
        payment_method: 'billet'
      }
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :gross_value, :description, :nfe_body, :customer_id,
                    :customer_type, :emites_service_values_id,
                    :emites_service_value_name, :finance_category,
                    :finance_revenue_center, :finance_receive_via,
                    :cobrato_charge_config_id, :cobrato_charge_config_name,
                    :cobrato_charge_template_id, :cobrato_charge_template_name,
                    :management_type, :days_until_automatic_nfe_emission,
                    :automatic_nfe_issue_date, :automatic_email_template_id,
                    :additional_information, :services,
                    :scheduled_update, :receivables_additional_information,
                    :payment_information
                  ]
end
