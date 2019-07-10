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

FactoryGirl.define do
  sequence(:company_name) { |n| "company_name_#{n}" }

  factory :contractor do
    company_name
    nric_no 'S7897795G'
    uen_number '52828649X'
    after(:create) do |contractor|
      create :contractor_account, contractor: contractor unless contractor.account
      ContractorsSkill.create(skill_id: 1, contractor: contractor)
      ContractorsSkill.create(skill_id: 2, contractor: contractor)
      create :credit, contractor: contractor
    end
  end
end
