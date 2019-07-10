require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:contractor) { create :contractor, credits: [] }
  let(:transaction) { Transaction.new(3, 'type', 50, 0, 'sgd', 'Completed', BtCustomer.new([PaymentMethod.new])) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:ensure_active)
    allow_any_instance_of(ApplicationController).to receive(:prepare_exception_notifier)
    sign_in contractor.account
  end

  describe 'POST #top_up (Braintree)' do
    it 'proceed top up payment when it is succeeded' do
      allow(Braintree::Transaction).to receive(:sale).and_return(
        Braintree::SuccessfulResult.new(transaction: transaction)
      )
      allow_any_instance_of(Paypal::Payment).to receive(:correctly_addressed?).and_return(true)
      params = { locale: 'en-sg', currency_code: 'SGD', amount: 50 }
      post :top_up, params
      contractor.reload
      credit = contractor.credits.last
      expect(credit.amount).to eq(50)
      expect(credit.deposit_type).to eq('paypal_top_up')
      expect(contractor.top_ups.last.amount).to eq(50)
      expect(subject).to redirect_to(billing_top_up_contractors_path(locale: 'en-sg'))
      expect(flash[:info]).to eq('Successfully topped up 50 SGD')
    end

    it 'does not proceed top up payment when it has an error' do
      allow(Braintree::Transaction).to receive(:sale).and_return(BraintreeError.new)
      allow_any_instance_of(Paypal::Payment).to receive(:correctly_addressed?).and_return(false)
      params = { locale: 'en-sg', currency_code: 'SGD', amount: 50 }
      expect { post :top_up, params }.to change { contractor.credits.count }.by(0)
      expect(subject).to redirect_to(billing_top_up_contractors_path(locale: 'en-sg'))
      expect(flash[:info]).to eq('Error processing transaction')
    end
  end

  describe 'POST #subscribe (Braintree)' do
    it 'proceed subscription payment when it is succeeded' do
      allow(Braintree::Customer).to receive(:create).and_return(transaction)
      allow(Braintree::Subscription).to receive(:create).and_return(
        Braintree::SuccessfulResult.new(transaction: transaction)
      )
      allow_any_instance_of(Paypal::Payment).to receive(:correctly_addressed?).and_return(true)
      params = { locale: 'en', currency_code: 'SGD', amount: 50 }
      post :subscribe, params
      contractor.reload
      subscription = contractor.subscriptions.last
      expect(subscription.price).to eq(50)
      expect(contractor.commercial_subscribe?).to eq(true)
      expect(subject).to redirect_to(billing_subscription_contractors_path)
      expect(flash[:info]).to eq('Successfully subscribed')
    end

    it 'does not proceed subscription when it has an error' do
      allow(Braintree::Customer).to receive(:create).and_return(transaction)
      allow(Braintree::Subscription).to receive(:create).and_return(BraintreeError.new)
      allow_any_instance_of(Paypal::SubscriptionPayment).to receive(:correctly_addressed?).and_return(false)
      params = { locale: 'en', currency_code: 'SGD', amount: 50 }
      expect { post :subscribe, params }.to change { contractor.subscriptions.count }.by(0)
      expect(subject).to redirect_to(billing_subscription_contractors_path)
      expect(flash[:info]).to eq('Error processing Subscription')
    end
  end

  describe 'POST #notify (Paypal)' do
    it 'proceed top up payment' do
      allow_any_instance_of(StringIO).to receive(:read).and_return('VERIFIED')
      allow_any_instance_of(Paypal::Payment).to receive(:correctly_addressed?).and_return(true)
      params = {
        locale: 'en', custom: "TopUp, #{contractor.id}, 50",
        txn_id: '123', txn_type: 'web_accept', mc_gross: '55.00',
        mc_fee: '2.20', mc_currency: 'SGD', payment_status: 'Completed'
      }
      post :notify, params
      contractor.reload
      credit = contractor.credits.last
      expect(credit.amount).to eq(55)
      expect(credit.deposit_type).to eq('paypal_top_up')
      expect(contractor.top_ups.last.amount).to eq(55)
      expect(response).to render_template(nil)
    end

    it 'proceed subscription payment' do
      allow_any_instance_of(StringIO).to receive(:read).and_return('VERIFIED')
      allow_any_instance_of(Paypal::Payment).to receive(:correctly_addressed?).and_return(true)
      # params = {
      #   locale: 'en', custom: "Subscription, #{contractor.id}",
      #   subscr_id: 'S123', txn_type: 'subscr_payment',
      #   mc_gross: '98.00', mc_fee: '3.83', mc_currency: 'SGD',
      #   payment_status: 'Completed'
      # }
      expect(response).to render_template(nil)
    end
  end
end

# rubocop:disable Style/StructInheritance
class Transaction < Struct.new(:id, :type, :amount, :service_fee_amount, :currency_iso_code, :status, :customer)
  attr_reader :created_at, :credit_card_details, :customer_details,
              :subscription_details, :updated_at, :merchant_account_id
end

class BraintreeError
  attr_reader :errors, :params, :transaction

  def success?
    false
  end
end

class BtCustomer < Struct.new(:payment_methods)
end

class PaymentMethod
  attr_reader :token
end
