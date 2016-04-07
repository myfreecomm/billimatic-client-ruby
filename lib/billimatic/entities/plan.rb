module Billimatic
  module Entities
    class Plan < Base
      attribute :id, Integer
      attribute :name, String
      attribute :description, String
      attribute :price, Decimal
      attribute :billing_period, Integer # 1, 2, 3, 6, 12
      attribute :trial_period, String # TODO Integer?
      attribute :redirect_url, String
    end
  end
end
