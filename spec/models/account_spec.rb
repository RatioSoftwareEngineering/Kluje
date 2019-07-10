# == Schema Information
#
# Table name: accounts
#
#  id                      :integer          not null, primary key
#  first_name              :string(150)
#  last_name               :string(150)
#  email                   :string(255)
#  encrypted_password      :string(255)      default(""), not null
#  role                    :string(255)
#  contractor_id           :integer
#  locale                  :string(255)      default("en"), not null
#  mobile_number           :string(255)
#  subscribe_newsletter    :boolean          default(TRUE), not null
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  deleted_at              :datetime
#  created_at              :datetime
#  updated_at              :datetime
#  suspended_at            :datetime
#  account_id              :integer
#  no_of_account           :integer
#  uid                     :string(255)
#  provider                :string(255)
#  property_agent_id       :integer
#  cea_number              :string(255)
#  facilities_manager_id   :integer
#  country_id              :integer
#  email_verification_code :string(255)
#  confirmation_token      :string(255)
#  confirmed_at            :datetime
#  confirmation_sent_at    :datetime
#  unconfirmed_email       :string(255)
#  agent                   :boolean
#  partner_code            :string(255)
#

require 'rails_helper'

describe Account do
  let(:account) { create :account }
  let(:contractor) { create :contractor }

  describe 'when saving a valid account' do
    it 'creates an account' do
      account = build :account
      expect(account.save).to be true
    end

    it 'creates a contractor account' do
      account = build(:contractor_account)
      expect(account.save).to be true
      expect(account.contractor?).to be true
    end
  end

  describe 'when saving an invalid account' do
    it 'cannot be saved without these mandatory fields' do
      [:first_name, :last_name, :email, :password].each do |field|
        account = build :account, field => nil
        expect(account.save).to be false
      end
    end

    it 'can be saved even if first name contains non-alphabet characters' do
      account = build :account, first_name: 'D4rwin'
      expect(account.save).to be true
    end

    it 'can be saved even if last name contains non-alphabet characters' do
      account = build :account, last_name: 'Des|gn'
      expect(account.save).to be true
    end

    context 'for a contractor' do
      it 'cannot be saved if company name is blank' do
        account = build(:contractor_account)
        account.contractor.company_name = nil
        expect(account.save).to be false
      end
    end
  end

  describe '#verify_mobile' do
    let(:number) { '81234567' }
    let!(:verification) { create :phone_verification, mobile_number: "65#{number}" }

    context 'homeowner' do
      let!(:account) { create :account, country: Country.find_by_name('Singapore') }

      context 'code correct' do
        it 'saves number' do
          expect(account.verify_mobile(number, verification.verification_code)).to be true
          expect(account.mobile_number).to eq "65#{number}"
        end
      end

      context 'code incorrect or expired' do
        it 'fails' do
          account.mobile_number = nil
          expect(account.verify_mobile(number, '00000')).to be false
          expect(account.mobile_number).to be nil

          verification.update_attributes(verification_code_expires_at: Time.zone.now - 1.second)
          expect(account.verify_mobile(number, verification.verification_code)).to be false
          expect(account.mobile_number).to be nil
        end
      end
    end

    context 'contractor' do
      let!(:account) { create :contractor_account }

      context 'code correct' do
        it 'saves number' do
          expect(account.verify_mobile(number, verification.verification_code)).to be true
          expect(account.mobile_number).to eq "65#{number}"
          expect(account.contractor.mobile_alerts).to be true
          verification.reload
          expect(verification.account).to eq account
          expect(verification.verified?).to be true
        end
      end

      context 'code incorrect or expired' do
        it 'fails' do
          account.mobile_number = nil
          account.contractor.mobile_alerts = false

          expect(account.verify_mobile(number, '00000')).to be false
          expect(account.mobile_number).to be nil
          expect(account.contractor.mobile_alerts).to be false

          verification.update_attributes(verification_code_expires_at: Time.zone.now - 1.second)
          expect(account.verify_mobile(number, verification.verification_code)).to be false
          expect(account.mobile_number).to be nil
          expect(account.contractor.mobile_alerts).to be false
        end
      end
    end
  end
end
