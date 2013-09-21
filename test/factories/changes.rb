# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :change do
    title "MyString"
    summary "MyText"
    impact "MyText"
    rollback "MyText"
    expected_change_date ""
    priority_id 1
    status_id 1
    system_id 1
    type_id 1
  end
end
