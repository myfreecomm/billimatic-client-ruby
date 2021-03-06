require 'spec_helper'

describe Billimatic::Entities::Invoice do
  let(:attributes) do
    {
      id: 1,
      contract_id: 20,
      gross_value: 100.0,
      number: '123',
      issue_date: '2016-09-19',
      state: 0,
      cancelled_automatically: false,
      description: 'FATURAMENTO',
      nfe_service: 'foo',
      nfe_verification: 'bar',
      created_at: '2016-09-17',
      payment_value: 100.0,
      emites_service_values_id: 1,
      finance_category: 'category',
      finance_revenue_center: 'revenue_center',
      finance_receive_via: 'receive_via',
      nfe_issued: true,
      nfe_issue_date: '2016-09-19',
      cobrato_charge_config_id: 2,
      receivables: [
        Billimatic::Entities::Receivable.new(
        id: 15,
        invoice_id: 1,
        due_date: '2016-09-22',
        value: 100.0,
        gross_value: 100.0
      )
      ],
      services: [
        Billimatic::Entities::Service.new(
        id: 1,
        service_item_id: 1,
        description: 'Descrição do serviço',
        units: 2,
        unit_value: 50.0,
        value: 100.0
      )
      ],
      attachments: [
        { id: 1, filename: 'foo.jpg', content_type: 'application/pdf', content: 'content', _destroy: false }
      ],
      payment_information: {
        id: 123,
        payment_method: 'payment_gateway'
      }
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :contract_id, :gross_value, :number, :issue_date,
                    :estimated_issue_date, :state, :cancelled_automatically,
                    :description, :nfe_service, :nfe_verification, :created_at,
                    :payment_value, :emites_service_values_id, :finance_category,
                    :finance_revenue_center, :finance_receive_via,
                    :myfinance_sale_account_id, :myfinance_sale_account_name,
                    :nfe_issued, :nfe_issue_date, :cobrato_charge_config_id,
                    :receivables, :services, :attachments, :nfe_body,
                    :accrual_date, :comments, :customer_id, :customer_type,
                    :emites_service_value_name, :cobrato_charge_config_name,
                    :cobrato_charge_template_id, :cobrato_charge_template_name,
                    :management_type, :days_until_automatic_nfe_emission,
                    :automatic_nfe_issue_date, :automatic_email_template_id,
                    :notification_ruler_id, :approval_status, :payment_information
                  ]
end
