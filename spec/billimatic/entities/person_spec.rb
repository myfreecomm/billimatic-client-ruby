require 'spec_helper'

describe Billimatic::Entities::Person do
  let(:attributes) do
    {
      id: 1,
      name: "Person",
      cpf: "313.491.466-25",
      email: "foo@person.com",
      zipcode: "01311000",
      address: "Avenida Paulista",
      number: "12",
      district: "Bela Vista",
      city: "São Paulo",
      state: "SP",
      client_since: "20/02/2014"
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :account_id, :name, :cpf, :email, :zipcode, :address,
                    :number, :complement, :district, :city, :state, :comments,
                    :client_since, :myfinance_customer_id, :myfinance_errors,
                    :created_at
                  ]
end
