FactoryBot.define do
  sequence(:question_title) { |n| "Question #{n}" }
  sequence(:question_body)  { |n| "Question text #{n}" }

  factory :question do
    title { generate(:question_title) }
    body  { generate(:question_body)  }
    user
  end

  factory :invalid_question, class: Question do
    title nil
    body  nil
    user
  end
end
