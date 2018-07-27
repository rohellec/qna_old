FactoryBot.define do
  sequence(:answer_body) { |n| "Answer text #{n}" }

  factory :answer do
    body { generate(:answer_body) }
    question
    user

    factory :accepted_answer do
      accepted true
    end

    factory :answer_with_attachment do
      attachments_attributes { [attributes_for(:answer_attachment)] }
    end
  end

  factory :invalid_answer, class: Answer do
    body nil
    question
    user
  end
end
