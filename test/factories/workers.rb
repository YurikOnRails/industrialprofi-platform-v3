FactoryBot.define do
  factory :worker do
    association :team
    sequence(:last_name) { |n| "Иванов#{n}" }
    sequence(:first_name) { |n| "Иван#{n}" }
    middle_name { 'Иванович' }
    sequence(:employee_number) { |n| "TN-#{n.to_s.rjust(6, '0')}" }
    department { 'Цех №1' }
    position { 'Электромонтёр 5р' }
    hire_date { Date.current - 1.year }
  end
end
