require 'spec_helper'

describe Billimatic::Entities::Customer do
  let(:attributes) do
    {
      id: 1,
      name: "Some Customer",
      email: "some@customer.com",
      document: "???",
      type: "???",
      address_information: {
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
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like "entity_attributes", [:id, :name, :email, :document, :type,
    :address_information]
end
