module Billimatic
  module Entities
    class Receivable < Base
      attribute :id, Integer
      attribute :invoice_id, Integer
      attribute :due_date, Date
      attribute :value, Decimal
      attribute :gross_value, Decimal
      attribute :payment_value, Decimal
      attribute :received_value, Decimal
      attribute :received_at, Date
      attribute :created_at, DateTime
      attribute :state, String
      attribute :payment_gateway_status, String
      attribute :cobrato_charge_id, Integer
      attribute :cobrato_errors, String
      attribute :myfinance_sale_id, Integer
      attribute :finance_receivable_id, Integer
      attribute :finance_entity_id, Integer
      attribute :myfinance_errors, String
    end
  end
end
