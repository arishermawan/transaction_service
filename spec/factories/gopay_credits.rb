# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gopay_credit do
    credit 0.0
    user_id 1
    user_type 'Customer'
  end
end
