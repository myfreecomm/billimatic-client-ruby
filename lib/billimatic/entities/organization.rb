module Billimatic
  module Entities
    class Organization < Base
      attribute :id, Integer
      attribute :account_id, Integer
      attribute :name, String
      attribute :company_name, String
      attribute :cnpj, String
      attribute :address, String
      attribute :number, String
      attribute :complement, String
      attribute :zipcode, String
      attribute :district, String
      attribute :city, String
      attribute :state, String
      attribute :created_at, DateTime
    end
  end
end
