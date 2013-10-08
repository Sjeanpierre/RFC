# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :approver do
    user nil
    change nil
    approved false
  end
end
