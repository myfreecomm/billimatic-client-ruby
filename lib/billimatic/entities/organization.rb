module Billimatic
  module Entities
    class Organization < Base
      attribute :id, Integer
      attribute :account_id, Integer
      attribute :name, String
      attribute :cnpj, String
      attribute :created_at, DateTime
    end
  end
end
