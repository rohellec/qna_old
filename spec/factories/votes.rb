FactoryBot.define do
  factory :vote do
    user

    factory :up_vote do
      association :votable
      value(1)
    end

    factory :down_vote do
      association :votable
      value(-1)
    end
  end
end
