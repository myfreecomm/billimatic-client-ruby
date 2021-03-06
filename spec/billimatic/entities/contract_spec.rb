require 'spec_helper'

describe Billimatic::Entities::Contract do
  let(:attributes) do
    {
      id: 1,
      name: 'Contrato',
      title: 'Título',
      token: '1234',
      description: 'Descrição',
      customer_id: 1,
      customer_type: 'Company',
      supplier_id: 2,
      supplier_type: 'Company',
      state: 1,
      init_date: '2016-05-02',
      created_at: "2016-05-02T16:55:10.000-03:00",
      kind: 'sale',
      registration_method: 'regular',
      overdue: false,
      status: 'established',
      cobrato_payment_gateway_charge_config_id: 12,
      cobrato_payment_gateway_charge_config_name: 'Config',
      overdue_automatic_management: true
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :name, :title, :token, :description, :customer_id,
                    :customer_type, :supplier_id, :supplier_type, :state,
                    :init_date, :end_date, :comments, :created_at, :kind,
                    :registration_method, :overdue, :valid_until, :status,
                    :cancel_date, :cancel_reason, :overdue_automatic_management,
                    :plan, :cobrato_payment_gateway_charge_config_id,
                    :cobrato_payment_gateway_charge_config_name
                  ]
end
