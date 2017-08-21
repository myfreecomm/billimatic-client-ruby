require 'spec_helper'

describe Billimatic::Entities::Company do
  let(:attributes) do
    {
      id: 1,
      account_id: 2,
      name: "Acme Inc",
      company_name: "Acme Incorporated",
      cnpj: "81.644.331/0001-66",
      state_inscription: "935.864.055.700",
      address: "Rua Tal",
      number: "1337",
      zipcode: "22290-080",
      district: "Centro",
      complement: "apto 42",
      city: "Rio de Janeiro",
      state: "RJ",
      contacts: "foo@bar.com, spam@eggs.co.uk",
      billing_contacts: "baz@bambam.com.br",
      comments: "Algum comentário",
      kind: "company",
      created_at: "2016-04-07T16:55:10.000-03:00"
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like "entity_attributes", [
                    :id, :account_id, :name, :company_name, :cnpj, :state_inscription,
                    :address, :number, :zipcode, :district, :complement, :city, :state,
                    :ibge_code, :contacts, :billing_contacts, :comments, :kind,
                    :client_since, :myfinance_customer_id, :myfinance_errors,
                    :created_at
                  ]
end
