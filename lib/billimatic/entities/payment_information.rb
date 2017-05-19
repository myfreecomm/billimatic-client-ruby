module Billimatic
  module Entities
    class PaymentInformation < Base
      attribute :id, Integer
      attribute :payment_method, String
      attribute :cobrato_card_id, Integer
      attribute :card_expiration_month, Integer
      attribute :card_expiration_year, Integer
      attribute :installments, Integer
      attribute :created_at, DateTime
    end
  end
end
