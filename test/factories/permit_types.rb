FactoryBot.define do
  factory :permit_type do
    association :team
    sequence(:name) { |n| "Охрана труда #{n}" }
    validity_months { 36 }
    national_standard { 'Постановление 2464' }
    penalty_amount { 130_000 }
    penalty_article { 'ст. 5.27.1 КоАП' }
    training_hours { 40 }
    requires_protocol { true }
  end
end
