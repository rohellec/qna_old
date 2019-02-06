FactoryBot.define do
  sequence(:question_title) { |n| "Question #{n}" }
  sequence(:question_body)  { |n| "Question text #{n}" }

  factory :question do
    title { generate(:question_title) }
    body  { generate(:question_body)  }
    user

    factory :answered_question do
      after(:create) do |question|
        create(:accepted_answer, question: question)
        question.update(answered: true)
      end
    end

    factory :question_with_attachment do
      attachments_attributes { [attributes_for(:question_attachment)] }
    end

    factory :question_with_attachments do
      attachments_attributes do
        [
          attributes_for(:question_attachment),
          attributes_for(:question_attachment)
        ]
      end
    end
  end

  factory :invalid_question, class: Question do
    title { nil }
    body  { nil }
    user
  end
end
