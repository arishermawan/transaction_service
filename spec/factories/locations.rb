# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    address "kolla sabang"
    coordinate "[-6.185512, 106.824948]"

    association :area
  end
end
