module Billimatic
  module Entities
    class Customer < Base
      attribute :id, Integer
      attribute :name, String
      attribute :email, String
      attribute :document, String
      attribute :type, String
      attribute :address_information, Billimatic::Entities::AddressInformation
    end
  end
end
