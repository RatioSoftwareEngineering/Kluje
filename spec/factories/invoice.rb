FactoryGirl.define do
  factory :invoice do
    sender { create :account }
    sender_type Account
    recipient { create :account }
    recipient_type Account
    job { create :job }
    amount 1000
    currency 'sgd'
    paid true
  end
end
