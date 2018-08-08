require 'spec_helper'

describe Billimatic::Entities::Organization do
  let(:attributes) do
    {
      id: 1,
      account_id: 2,
      name: "Acme Inc",
      cnpj: "81.644.331/0001-66",
      created_at: "2016-04-07T16:55:10.000-03:00"
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :account_id, :name, :company_name, :cnpj, :address,
                    :number, :complement, :zipcode, :district, :city, :state,
                    :created_at
                  ]
end
