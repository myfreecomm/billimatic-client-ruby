module Billimatic
  module Entities
    class Person < Base
      attribute :id, Integer
      attribute :account_id, Integer
      attribute :name, String
      attribute :cpf, String
      attribute :email, String
      attribute :zipcode, String
      attribute :address, String
      attribute :number, String
      attribute :complement, String
      attribute :district, String
      attribute :city, String
      attribute :state, String
      attribute :comments, String
      attribute :client_since, Date
      attribute :created_at, DateTime
    end
  end
end
