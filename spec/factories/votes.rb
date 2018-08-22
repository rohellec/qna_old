FactoryBot.define do
  factory :vote do
    user

    factory :up_vote do
      association :votable
      value 1
    end

    factory :question_up_vote do
      association :votable, factory: :question
      value 1
    end

    factory :question_down_vote do
      association :votable, factory: :question
      value -1
    end
  end
end
