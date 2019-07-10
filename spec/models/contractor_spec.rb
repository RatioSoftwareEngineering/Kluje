# == Schema Information
#
# Table name: contractors
#
#  id                           :integer          not null, primary key
#  company_name                 :string(255)      not null
#  company_street_no            :string(255)
#  company_street_name          :string(255)
#  company_unit_no              :string(255)
#  company_building_name        :string(255)
#  company_postal_code          :string(255)
#  company_name_slug            :string(255)      not null
#  company_logo                 :string(255)
#  nric_no                      :string(255)
#  uen_number                   :string(255)
#  bca_license                  :string(255)
#  hdb_license                  :string(255)
#  billing_name                 :string(255)
#  billing_address              :text(65535)
#  billing_postal_code          :string(255)
#  billing_phone_no             :string(255)
#  mobile_alerts                :boolean          default(TRUE), not null
#  email_alerts                 :boolean          default(TRUE), not null
#  score                        :integer
#  deleted_at                   :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#  company_description          :text(65535)
#  pub_license                  :string(255)
#  ema_license                  :string(255)
#  case_member                  :string(255)
#  scal_member                  :string(255)
#  bizsafe_member               :string(255)
#  selected_header_image        :string(255)
#  crop_x                       :string(255)
#  crop_y                       :string(255)
#  crop_w                       :string(255)
#  crop_h                       :string(255)
#  parent_id                    :integer
#  sms_count                    :integer
#  is_deactivated               :boolean
#  office_number                :string(255)
#  verified                     :boolean
#  photo_id                     :string(255)
#  business_registration        :string(255)
#  bids_count                   :integer          default(0)
#  average_rating               :float(24)        default(0.0)
#  approved                     :boolean          default(FALSE)
#  commercial                   :boolean          default(FALSE), not null
#  accept_agreement             :boolean
#  company_red                  :datetime
#  company_rn                   :string(255)
#  company_rd                   :string(255)
#  date_incor                   :datetime
#  relevant_activitie           :string(255)
#  association_name             :string(255)
#  membership_no                :string(255)
#  financial_report             :string(255)
#  bank_statement               :string(255)
#  legal                        :boolean
#  legal_text                   :string(255)
#  request_commercial           :boolean          default(FALSE)
#  verification_request         :boolean          default(FALSE)
#  commercial_registration_date :datetime
#

require 'rails_helper'

describe Contractor do
  let(:contractor) { create :contractor }
  let(:account) { create :account, contractor: contractor }

  describe 'postal code' do
    it 'allows non-numeric characters' do
      contractor.company_postal_code = '123APASD132-213'
      expect(contractor.save).to be true
    end

    it 'does allows postal code to be shorter or longer than 6 digits' do
      %w(12345 1234567891939).each do |postal_code|
        contractor.company_postal_code = postal_code
        expect(contractor.save).to be true
      end
    end

    it 'changes the postal_code if it is valid' do
      contractor.company_postal_code = '139951'
      expect(contractor.save).to be true
      expect(contractor.reload.company_postal_code).to eq '139951'
    end

    it 'allows postal code to start with 0' do
      contractor.company_postal_code = '012345'
      expect(contractor.save).to be true
      expect(contractor.reload.company_postal_code).to eq '012345'
    end

    it 'allows empty postal code' do
      contractor.company_postal_code = ''
      expect(contractor.save).to be true
      expect(contractor.reload.company_postal_code).to eq ''
    end
  end

  describe 'nric no' do
    it 'does not allow invalid NRIC no' do
      contractor.nric_no = '5820829-182-99'
      expect(contractor.save).to be false
    end

    it 'changes the nric_no if it is valid' do
      %w(S8598385G T8598385F).each do |nric|
        contractor.nric_no = nric
        expect(contractor.save).to be true
        expect(contractor.reload.nric_no).to eq nric
      end
    end
  end

  describe 'hdb license' do
    it 'does not allow invalid prefix' do
      contractor.hdb_license = 'FOO8698787'
      expect(contractor.save).to be false
    end

    it 'changes the hdb_license if it is valid' do
      contractor.hdb_license = 'HB139951'
      expect(contractor.save).to eq true
      expect(contractor.reload.hdb_license).to eq 'HB139951'
    end
  end

  describe 'uen number' do
    it 'does not allow invalid UEN no' do
      %w(1234 S123456 A10LL1234G).each do |uen_no|
        contractor.uen_number = uen_no
        expect(contractor.save).to be false
      end
    end

    it 'changes the uen_number if it is valid' do
      %w(12345678F 123456789F T11LL1234F).each do |uen_no|
        contractor.uen_number = uen_no
        expect(contractor.save).to be true
        expect(contractor.reload.uen_number).to eq uen_no
      end
    end
  end
end
