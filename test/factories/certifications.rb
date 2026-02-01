FactoryBot.define do
  factory :certification do
    worker
    permit_type { association :permit_type, team: worker.team }
    issued_at { Date.current - 6.months }
    expires_at { Date.current + 6.months }
    sequence(:document_number) { |n| "УД-2024-#{n.to_s.rjust(4, '0')}" }
    sequence(:protocol_number) { |n| "ПР-2024-#{n.to_s.rjust(4, '0')}" }
    protocol_date { issued_at }
    training_center { 'УЦ Профессионал' }
    next_check_date { nil }
  end
end
