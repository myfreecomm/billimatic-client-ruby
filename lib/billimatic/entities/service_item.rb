module Billimatic
  module Entities
    class ServiceItem < Base
      attribute :id, Integer
      attribute :account_id, Integer
      attribute :name, String
      attribute :description, String
      attribute :value, Decimal
      attribute :unit, String
    end
  end
end
