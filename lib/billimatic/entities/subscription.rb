module Billimatic
  module Entities
    class Subscription < Base
      attribute :id, Integer
      attribute :plan_id, Integer
      attribute :customer, Billimatic::Entities::Customer
      attribute :address_information, Billimatic::Entities::AddressInformation
    end
  end
end
