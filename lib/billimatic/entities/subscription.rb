module Billimatic
  module Entities
    class Subscription < Contract
      attribute :plan_id, Integer
      attribute :customer, Customer
    end
  end
end
