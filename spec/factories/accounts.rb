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

# rubocop:disable Style/FormatString
FactoryGirl.define do
  sequence(:email) { |n| "account#{n}@example.com" }
  sequence(:mobile_number) { |n| "6587#{'%06d' % n}" }

  factory :account do
    first_name 'John'
    last_name 'Doe'
    email
    mobile_number
    password '123456'
    confirmed_at Time.zone.now
    country
  end

  factory :contractor_account, class: Account do
    first_name 'John'
    last_name 'Doe'
    email
    mobile_number
    password '123456'
    confirmed_at Time.zone.now
    contractor
    country
    after(:create) do |a|
      a.country.cities.each do |c|
        ContractorsCity.create contractor: a.contractor, city: c
      end
    end
  end
end
