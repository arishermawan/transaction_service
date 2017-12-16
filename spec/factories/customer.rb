
FactoryGirl.define do
  factory :customer do
    sequence(:email) { |n| "email-#{n}@goscholar.com" }
    password "abc123"
    password_confirmation "abc123"
  end

  factory :invalid_customer, parent: :user do
    email nil
    password nil
    password_confirmation nil
  end
end
