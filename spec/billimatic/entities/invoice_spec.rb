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
      services: [
        Billimatic::Entities::Service.new(
        id: 1,
        service_item_id: 1,
        units: 2,
        unit_value: 50.0,
        value: 100.0
      )
      ],
      attachments: [
        { id: 1, filename: 'foo.jpg', content_type: 'application/pdf', content: 'content', _destroy: false }
      ]
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :contract_id, :gross_value, :number, :issue_date,
                    :state, :description, :nfe_service, :nfe_verification,
                    :created_at, :payment_value, :emites_service_values_id,
                    :finance_category, :finance_revenue_center, :finance_receive_via,
                    :nfe_issued, :nfe_issue_date, :cobrato_charge_config_id,
                    :services, :attachments
                  ]
end
