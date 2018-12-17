require 'spec_helper'

describe Billimatic::Resources::Base do

  module Billimatic::Resources
    class Dummy < Base
      crud :list, :create, :show, :destroy

      def parseable
        response = http.get("/1mayrfq1")
        parsed_body(response)
      end

      def fail
        http.get("/fail")
      end

      def timeout
        http.get("/timeout")
      end

      def notifiable(id)
        "notifiable [#{id}]"
      end

      notify :notifiable
    end
  end

  let(:http) { Billimatic::Http.new("bfe97f701f615edf41587cbd59d6a0e8") }
  let(:request) { double(body: nil, return_code: :ok) }

  subject { Billimatic::Resources::Dummy.new(http) }

  before do
    allow(Billimatic.configuration).to receive(:url).and_return("http://requestb.in")
  end

  describe 'crud' do
    context 'when subclass do not especify the crud method' do
      it 'should raise error' do
        expect{
          subject.update(123, name: 'test')
        }.to raise_error(RuntimeError, "Dummy do not implement the update method")
      end
    end

    context 'when calling specific requests methods' do
      it 'returns an entity' do
        response = double(:response)
        expect(subject.http).to receive(:get).with('/dummys/1').and_yield(response)
        expect(subject).to receive(:respond_with_entity).with(response)
        subject.show(1)
      end

      it 'returns a collection' do
        response = double(:response)
        expect(subject.http).to receive(:get).with('/dummys').and_yield(response)
        expect(subject).to receive(:respond_with_collection).with(response)
        subject.list
      end
    end
  end

  describe "#parsed_body" do
    before do
      allow(http).to receive(:send_request).and_return(request)
    end

    it "does not raise an error" do
      expect { subject.parseable }.not_to raise_error
    end

    it "response returns an empty hash" do
      expect(subject.parseable).to eq({})
    end
  end

  describe ".notify" do
    before do
      allow(http).to receive(:send_request).and_return(request)
    end

    class FakeListener
      def call(result, args)
        [result, args]
      end
    end

    let(:listener) { FakeListener.new }

    before do
      Billimatic.subscribe("billimatic.dummy.notifiable", listener)
    end

    it "does not affect method return" do
      expect(subject.notifiable(42)).to eq("notifiable [42]")
    end

    it "notifies listeners about event" do
      expect(listener).to receive(:call).with("notifiable [42]", [42]).
        and_return(["notifiable [42]", [42]])
      subject.notifiable(42)
    end
  end

  context "when request fails" do
    it "raises an RequestError" do
      Typhoeus.stub(/fail/).and_return(Typhoeus::Response.new(return_code: nil))
      expect { subject.fail }.to raise_error(Billimatic::RequestError)
    end

    it "raises an RequestTimeout" do
      Typhoeus.stub(/timeout/).and_return(Typhoeus::Response.new(return_code: :operation_timedout))
      expect { subject.timeout }.to raise_error(Billimatic::RequestTimeout)
    end
  end

  describe '#collection_name' do
    it 'when simple class name' do
      allow(subject).to receive(:base_klass).and_return('Webhook')
      expect(subject.collection_name).to eql('webhooks')
    end

    it 'when composed class name' do
      allow(subject).to receive(:base_klass).and_return('InvoiceRule')
      expect(subject.collection_name).to eql('invoice_rules')
    end
  end

  describe '#respond_with_openstruct' do
    it 'returns a collection with openstruct' do
      response = double(:response)
      expect(response).to receive(:body).and_return({name: 'test'}.to_json)
      expect(
        subject.send(:respond_with_openstruct, response)
      ).to eql(OpenStruct.new(name: 'test'))
    end
  end

  describe '#list_by_organization id' do
    let(:response) { double(:response) }

    subject { described_class.new(http) }

    it 'issues a get request on http object for a collection path scoped by organization' do
      allow(subject).to receive(:resource_base_path).and_return '/dummies'
      expect(http).to receive(:get).once.with('/organizations/123/dummies').and_yield response
      expect(subject).to receive(:respond_with_collection).once.with(response)

      subject.list_by_organization(123)
    end
  end

  describe '#show_by_organization organization_id, entity_id' do
    let(:response) { double(:response) }

    it 'issues a get request on http object for an entity path scoped by organization' do
      allow(subject).to receive(:resource_base_path).and_return '/dummies'
      expect(http).to receive(:get).once.with('/organizations/123/dummies/456').and_yield response
      expect(subject).to receive(:respond_with_entity).once.with(response)

      subject.show_by_organization(123, 456)
    end
  end
end
