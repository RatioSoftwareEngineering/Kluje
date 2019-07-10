# == Schema Information
#
# Table name: countries
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  native_name                    :string(255)
#  cca2                           :string(255)
#  cca3                           :string(255)
#  flag                           :string(255)
#  currency_code                  :string(255)
#  price_format                   :string(255)
#  default_phone_code             :string(255)
#  available                      :boolean
#  time_zone                      :string(255)
#  top_up_amounts                 :text(65535)
#  sms_bundle_price               :decimal(13, 2)   default(9.99)
#  postal_codes                   :boolean          default(TRUE)
#  paypal                         :boolean          default(FALSE)
#  braintree                      :boolean          default(FALSE)
#  default_locale                 :string(255)      default("en")
#  commercial                     :boolean          default(FALSE)
#  residential_subscription_price :decimal(13, 2)   default(0.0)
#  commercial_subscription_price  :decimal(13, 2)   default(0.0)
#  subscription_flag              :boolean          default(FALSE)
#
# Indexes
#
#  index_countries_on_name  (name)
#

FactoryGirl.define do
  factory :country do
    name 'Singapore'
    native_name 'Singapore'
    cca2 'sg'
    cca3 'sin'
    currency_code 'sgd'
    price_format '$%.2f'
    default_phone_code '65'
    available true
    time_zone 'Asia/Singapore'
    top_up_amounts [50, 250, 500]
    after(:create) do |c|
      City.create country: c, name: 'Singapore'
    end
  end
end
