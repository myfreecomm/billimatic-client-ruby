require 'spec_helper'

describe Billimatic::Entities::Receivable do
  let(:attributes) do
    {
      id: 1,
      invoice_id: 2,
      due_date: '2016-09-22',
      value: 100.0,
      gross_value: 100.0,
      payment_value: 90.0,
      received_value: 90.0,
      received_at: '2016-09-21',
      state: 'received',
      cobrato_charge_id: 1
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :invoice_id, :due_date, :value, :gross_value,
                    :payment_value, :received_value, :received_at,
                    :created_at, :state, :payment_gateway_status,
                    :cobrato_charge_id, :cobrato_errors, :finance_receivable_id,
                    :myfinance_sale_id, :finance_entity_id, :myfinance_errors
                  ]
end
