require 'spec_helper'

describe Billimatic::Resources::Invoice do
  let(:entity_klass) { Billimatic::Entities::Invoice }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    it 'raises Billimatic::RequestError if contract is not found' do
      VCR.use_cassette('/invoices/search/failure/contract_not_found') do
        expect {
          subject.search(
            contract_id: 7392,
            issue_date_from: '02-05-2016',
            issue_date_to: '03-05-2016'
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if search params are invalid' do
      VCR.use_cassette('/invoices/search/failure/invalid_search_parameters') do
        expect {
          subject.search(
            contract_id: 6666,
            issue_date_from: 'foo',
            issue_date_to: ''
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'returns a collection of invoices matching the desired issue_date range' do
      VCR.use_cassette('/invoices/search/success/issue_date_range_matches') do
        invoices = subject.search(
          contract_id: 6666,
          issue_date_from: '02-05-2015',
          issue_date_to: '03-05-2017'
        )

        expect(invoices).not_to be_empty
        invoices.each do |invoice|
          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql 6666
        end
      end
    end

    it 'returns an empty array if no invoices match the desired range' do
      VCR.use_cassette('/invoices/search/success/no_matches') do
        invoices = subject.search(
          contract_id: 6666,
          issue_date_from: '02-05-2019',
          issue_date_to: '03-05-2020'
        )

        expect(invoices).to be_empty
      end
    end
  end
end
