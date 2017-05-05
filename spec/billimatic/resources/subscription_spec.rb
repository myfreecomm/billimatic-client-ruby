require 'spec_helper'

describe Billimatic::Resources::Subscription do
  let(:entity_klass) { Billimatic::Entities::Subscription }
  let(:http) { Billimatic::Http.new('4d34754cd68bbe74d725f6c8c9f6b48f') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#show :token' do
    it 'returns the subscription that has the token attached' do
      VCR.use_cassette('subscriptions/show_by_token/success') do
        subscription = subject.show(token: '330b961a1969e7ac435c811594c46e8e')

        expect(subscription).to be_a entity_klass
        expect(subscription.token).to eql '330b961a1969e7ac435c811594c46e8e'
        expect(subscription.state).to eql('active')
        expect(subscription.status).to eql('established')
        expect(subscription.name).not_to be_nil
      end
    end

    it 'returns an error if subscription is not found with the given token' do
      VCR.use_cassette('subscriptions/show_by_token/failure') do
        expect {
          subject.show(token: 'foo123')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#create' do
    let(:subscription_params) do
      {
        plan_id: 1,
        customer: {
          name: "Empresa de Teste",
          email: "teste@companhia.com",
          document: "35.511.438/0001-19",
          type: "Company",
          address_information: {
            address: "Praça da Sé",
            number: "12",
            district: "Sé",
            zipcode: "01001000",
            city: "São Paulo",
            state: "SP"
          }
        }
      }
    end

    it 'returns the newly created subscription' do
      VCR.use_cassette('subscriptions/create/success') do
        subscription = subject.create(subscription_params)

        expect(subscription).to be_a entity_klass
        expect(subscription.name).to eql 'Assinatura Empresa de Teste - TESTE BILLIMATIC Myfinance Bronze'
        expect(subscription.status).to eql 'trial'
        expect(subscription.state).to eql 'active'
        expect(subscription.plan.id).to eql subscription_params.fetch(:plan_id)
      end
    end

    it 'returns an error if plan is not found' do
      VCR.use_cassette('subscriptions/create/plan_not_found') do
        subscription_params[:plan_id] = 80000

        expect {
          subject.create(subscription_params)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#checkout' do
    let(:checkout_params) do
      {
        customer: {
          type: 'Person',
          name: 'Consumidor 8',
          email: 'consumidor_8@teste.com',
          document: '162.558.592-66',
          address_information: {
            address: 'Avenida Brigadeiro Luís Antônio',
            number: '12',
            complement: 'apto. 111',
            zipcode: '01402000',
            district: 'Jardim Paulista',
            city: 'São Paulo',
            state: 'SP'
          }
        },
        payment_information: {
          type: 'billet'
        }
      }
    end

    it "returns not found if subscription isn't found by token sent" do
      VCR.use_cassette('/subscriptions/checkout/failure/subscription_not_found') do
        expect {
          subject.checkout(checkout_params, token: "FOO")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns unprocessable entity if customer required params are missing' do
      VCR.use_cassette('/subscriptions/checkout/failure/missing_customer_params') do
        checkout_params[:customer].delete(:name)
        checkout_params[:customer][:address_information].delete(:zipcode)

        expect {
          subject.checkout(checkout_params, token: "1870c414e05ac8a6dfb3c529b0a790f6")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['customer']).to have_key 'name'
          expect(error.body['errors']['customer']['address_information']).to have_key 'zipcode'
        end
      end
    end

    it 'returns unprocessable entity if customer type is not sent' do
      VCR.use_cassette('/subscriptions/checkout/failure/missing_customer_type') do
        checkout_params[:customer].delete(:type)

        expect {
          subject.checkout(checkout_params, token: "1870c414e05ac8a6dfb3c529b0a790f6")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['customer']).to have_key 'type'
        end
      end
    end

    it 'returns unprocessable entity if checkout is paid in payment_gateway without card params' do
      VCR.use_cassette('/subscriptions/checkout/failure/missing_card_params') do
        checkout_params[:payment_information][:type] = 'payment_gateway'

        expect {
          subject.checkout(checkout_params, token: "1870c414e05ac8a6dfb3c529b0a790f6")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['payment_information']).to have_key 'card_brand'
          expect(error.body['errors']['payment_information']).to have_key 'card_number'
        end
      end
    end

    it 'returns unprocessable entity on checkout attempt for unavailable payment method' do
      VCR.use_cassette('/subscriptions/checkout/failure/unavailable_payment_method') do
        checkout_params[:payment_information][:type] = 'payment_gateway'
        checkout_params[:payment_information][:card_brand] = 'Visa'
        checkout_params[:payment_information][:card_number] = '4012001038443335'
        checkout_params[:payment_information][:card_holder_name] = 'CONSUMIDOR OITO'
        checkout_params[:payment_information][:card_expiration_month] = '12'
        checkout_params[:payment_information][:card_expiration_year] = '2019'
        checkout_params[:payment_information][:card_security_code] = '123'

        expect {
          subject.checkout(checkout_params, token: "dad1b1d450e528c6436ed153d7ab7c42")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['payment_information']).to have_key 'type'
          expect(error.body['errors']['payment_information']['type']).not_to be_empty
        end
      end
    end

    it 'returns unprocessable entity on checkout attempt for invalid payment method' do
      VCR.use_cassette('/subscriptions/checkout/failure/invalid_payment_method') do
        checkout_params[:payment_information][:type] = 'foo'

        expect {
          subject.checkout(checkout_params, token: "1870c414e05ac8a6dfb3c529b0a790f6")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['payment_information']).to have_key 'type'
          expect(error.body['errors']['payment_information']['type']).not_to be_empty
        end
      end
    end

    it 'returns unprocessable entity on a duplicated checkout attempt' do
      VCR.use_cassette('/subscriptions/checkout/failure/duplicated_checkout') do
        expect {
          subject.checkout(checkout_params, token: "0a06eeefb50a512dc1403225e26496f8")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['customer']).to have_key 'checkout'
        end
      end
    end

    context 'when localhost tmp' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = "http://localhost:3000" }

      it 'successfully processes checkout paid in payment gateway' do
        VCR.use_cassette('/subscriptions/checkout/success/paid_in_payment_gateway') do
          checkout_params[:payment_information][:type] = 'payment_gateway'
          checkout_params[:payment_information][:card_brand] = 'Visa'
          checkout_params[:payment_information][:card_number] = '4012001038443335'
          checkout_params[:payment_information][:card_holder_name] = 'CONSUMIDOR OITO'
          checkout_params[:payment_information][:card_expiration_month] = '12'
          checkout_params[:payment_information][:card_expiration_year] = '2019'
          checkout_params[:payment_information][:card_security_code] = '123'

          result = subject.checkout(
            checkout_params, token: "2a289e29901e0a98fce56723015cefde"
          )

          expect(result).to be_a entity_klass
          expect(result.end_date).to be_nil
          expect(result.state).to eql 'active'
          expect(result.status).to eql 'established'
          expect(result.payment_information.installments).to eql(1)
        end
      end
    end

    it 'successfully processes checkout paid in billet' do
      VCR.use_cassette('/subscriptions/checkout/success/paid_in_billet') do
        checkout_params[:customer][:type] = 'Company'
        checkout_params[:customer][:name] = "Pessoa Jurídica 8"
        checkout_params[:customer][:email] = "pj_8@teste.com"
        checkout_params[:customer][:document] = "51.251.041/0001-91"
        checkout_params[:customer][:address_information][:complement] = nil

        result = subject.checkout(
          checkout_params, token: "dad1b1d450e528c6436ed153d7ab7c42"
        )

        expect(result).to be_a entity_klass
        expect(result.end_date).to be_nil
        expect(result.state).to eql 'active'
        expect(result.status).to eql 'established'
      end
    end
  end

  describe '#change_plan' do
    it 'returns not found if subscription token is wrong' do
      VCR.use_cassette('/subscriptions/change_plan/failure/wrong_token') do
        expect {
          subject.change_plan(token: "FOO", new_plan_id: 2)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns not found when plan is not found' do
      VCR.use_cassette('/subscriptions/change_plan/failure/plan_not_found') do
        expect {
          subject.change_plan(token: "ec0aebe3ed4bd79fd4c238c0b6470c4a", new_plan_id: 800000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'successfully processes plan change on subscription' do
      VCR.use_cassette('/subscriptions/change_plan/success') do
        subscription = subject.change_plan(
          token: "ec0aebe3ed4bd79fd4c238c0b6470c4a", new_plan_id: 2
        )

        expect(subscription).to be_a entity_klass
        expect(subscription.plan.id).to eql 2
      end
    end
  end

  describe '#update_payment_information' do
    let(:payment_information_params) do
      {
        payment_information: {
          type: 'billet'
        }
      }
    end

    let(:payment_gateway_params) do
      {
        payment_information: {
          type: 'payment_gateway',
          card_brand: 'Visa',
          card_number: '4012001037141112',
          card_holder_name: 'PRE PAGO TESTE',
          card_expiration_month: '12',
          card_expiration_year: '2021',
          card_security_code: '123'
        }
      }
    end

    it 'returns not found when subscription token is wrong' do
      VCR.use_cassette('/subscriptions/update_payment_information/failure/wrong_token') do
        expect {
          subject.update_payment_information(
            payment_information_params, token: "FOO"
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it "returns unprocessable entity when form isn't valid" do
      VCR.use_cassette('/subscriptions/update_payment_information/failure/invalid_payment_information') do
        payment_gateway_params[:payment_information].delete(:card_expiration_month)
        payment_gateway_params[:payment_information].delete(:card_expiration_year)
        payment_gateway_params[:payment_information].delete(:card_security_code)

        expect {
          subject.update_payment_information(
            payment_gateway_params,
            token: "6c8b6e236c8c3a408e1196f456ebe5d1"
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['payment_information']).to have_key 'card_expiration_month'
          expect(error.body['errors']['payment_information']).to have_key 'card_expiration_year'
          expect(error.body['errors']['payment_information']).to have_key 'card_security_code'
        end
      end
    end

    it 'returns unprocessable entity when an attempt is made to update to an unavailable payment_method' do
      VCR.use_cassette('/subscriptions/update_payment_information/failure/unavailable_payment_method') do
        expect {
          subject.update_payment_information(
            payment_gateway_params,
            token: "84b794193d748966adb074ea1ea7dfbf"
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
          expect(error.body['errors']['payment_information']).to have_key 'type'
        end
      end
    end

    it 'processes update successfully to billet' do
      VCR.use_cassette('/subscriptions/update_payment_information/success/changed_to_billet') do
        result = subject.update_payment_information(
          payment_information_params, token: "6c8b6e236c8c3a408e1196f456ebe5d1"
        )

        expect(result).to be_a entity_klass
        expect(result.payment_information.payment_method).to eql 'billet'
      end
    end

    it 'processes update successfully to payment_gateway' do
      VCR.use_cassette('/subscriptions/update_payment_information/success/changed_to_payment_gateway') do
        result = subject.update_payment_information(
          payment_gateway_params, token: "84b794193d748966adb074ea1ea7dfbf"
        )

        expect(result).to be_a entity_klass
        expect(result.payment_information.payment_method).to eql 'payment_gateway'
      end
    end
  end

  describe '#cancel' do
    it "successfully sets a subscription to 'cancelled' and cancel_date as today" do
      VCR.use_cassette('subscriptions/cancel/success/without_params') do
        subscription = subject.cancel(token: 'dad1b1d450e528c6436ed153d7ab7c42')

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.state).to eql 'inactive'
        expect(subscription.cancel_date).to eql Date.parse('2017-04-10')
        expect(subscription.cancel_reason).to be_nil
      end
    end

    it 'successfully cancels subscription and sets cancel_date' do
      VCR.use_cassette('subscriptions/cancel/success/with_cancel_date') do
        subscription = subject.cancel(
          token: '1870c414e05ac8a6dfb3c529b0a790f6',
          cancel_date: Date.parse("04-09-2017")
        )

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.state).to eql 'inactive'
        expect(subscription.cancel_date).to eql Date.parse('2017-09-04')
        expect(subscription.cancel_reason).to be_nil
      end
    end

    it 'successfully cancels subscription and sets cancel_reason' do
      VCR.use_cassette('subscriptions/cancel/success/with_cancel_reason') do
        subscription = subject.cancel(
          token: '330b961a1969e7ac435c811594c46e8e',
          cancel_reason: "Cancelamento via API de e-commerce"
        )

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.state).to eql 'inactive'
        expect(subscription.cancel_date).to eql Date.parse('2017-04-10')
        expect(subscription.cancel_reason).to eql "Cancelamento via API de e-commerce"
      end
    end

    it 'successfully cancels subscription and sets both cancellation params' do
      VCR.use_cassette('subscriptions/cancel/success/with_cancellation_params') do
        subscription = subject.cancel(
          token: '0a06eeefb50a512dc1403225e26496f8',
          cancel_date: Date.parse("08/04/2017"),
          cancel_reason: "Cancelamento via API de e-commerce"
        )

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.cancel_date).to eql Date.parse('2017-04-08')
        expect(subscription.cancel_reason).to eql "Cancelamento via API de e-commerce"
      end
    end

    it 'returns an error if subscription is not found' do
      VCR.use_cassette('subscriptions/cancel/not_found') do
        expect {
          subject.cancel(token: 'foo123')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe "#checkout_url" do
    before do
      Billimatic.configuration.host = "https://test.host"
    end

    it "returns url to checkout on Billimatic app" do
      url = subject.checkout_url(token: "foobar")
      expect(url).to eq("https://test.host/subscriptions/checkout/foobar")
    end
  end
end
