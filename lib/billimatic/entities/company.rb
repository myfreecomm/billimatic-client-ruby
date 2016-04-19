module Billimatic
  module Entities
    class Company < Base
      attribute :id, Integer
      attribute :account_id, Integer
      attribute :name, String
      attribute :company_name, String
      attribute :cnpj, String
      attribute :address, String
      attribute :number, String
      attribute :zipcode, String
      attribute :district, String
      attribute :complement, String
      attribute :city, String
      attribute :state, String
      attribute :ibge_code, String
      attribute :contacts, String
      attribute :billing_contacts, String
      attribute :comments, String
      attribute :kind, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end
  end
end