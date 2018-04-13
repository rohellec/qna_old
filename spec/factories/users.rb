FactoryBot.define do
  sequence(:email) { |n| "user#{n}@test.com" }

  factory :user do
    email
    password "12345678"
    password_confirmation "12345678"

    factory :confirmed_user do
      confirmed_at { Time.current }
    end
  end
end
