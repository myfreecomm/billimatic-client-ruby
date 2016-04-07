require "spec_helper"

describe Billimatic::Signature do
  let(:body) do
    {
      test: true
    }
  end

  let(:secret)             { 'my-billimatic-secret' }
  let(:billimatic_request_id) { 'anything' }
  let(:billimatic_signature)  { OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, "#{billimatic_request_id}#{body}") }

  describe '#check?' do
    subject { described_class.new(secret) }

    context 'when headers are ok' do
      it 'returns true' do
        expect(subject.check?(billimatic_request_id, billimatic_signature, body)).to be_truthy
      end
    end

    context 'when headers are not ok' do
      let(:billimatic_signature) { OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, "anotherThing#{body}") }

      it 'returns false' do
        expect(subject.check?(billimatic_request_id, billimatic_signature, body)).to be_falsy
      end
    end
  end
end
