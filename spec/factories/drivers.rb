
FactoryGirl.define do
  factory :driver do
    sequence(:email) { |n| "email-#{n}@gojek.com" }
    password "abc123"
    password_confirmation "abc123"
  end

  factory :invalid_driver, parent: :driver do
    email nil
    password nil
    password_confirmation nil
  end
end
