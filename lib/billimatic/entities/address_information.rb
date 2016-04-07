module Billimatic
  module Entities
    class AddressInformation < Base
      attribute :id, Integer
      attribute :address, String
      attribute :number, String
      attribute :complement, String
      attribute :district, String
      attribute :zipcode, String
      attribute :city, String
      attribute :state, String
      attribute :ibge_code, String
    end
  end
end
