module Billimatic
  module Entities
    class EntityServiceItem < Base
      attribute :id, Integer
      attribute :name, String
      attribute :unit_value, Decimal
      attribute :units, Decimal
      attribute :value, Decimal
    end
  end
end
