require 'spec_helper'

describe Billimatic::Entities::AddressInformation do
  let(:attributes) do
    {
      id: 1,
      address: "Rua Tal",
      number: "1337",
      complement: "apto 42",
      district: "Centro",
      zipcode: "22290-080",
      city: "Rio de Janeiro",
      state: "RJ",
      ibge_code: "12345"
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like "entity_attributes", [:id, :address, :number, :complement,
    :district, :zipcode, :city, :state, :ibge_code]
end
