FactoryBot.define do
  sequence(:answer_body) { |n| "Answer text #{n}" }

  factory :answer do
    body { generate(:answer_body) }
    question
    user

    factory :accepted_answer do
      accepted { true }
    end

    factory :answer_with_votes do
      transient do
        votes_count { 1 }
      end

      after(:create) do |answer, evaluator|
        create_list(:up_vote, evaluator.votes_count, votable: answer)
      end
    end

    factory :answer_with_attachment do
      attachments_attributes { [attributes_for(:answer_attachment)] }
    end

    factory :answer_with_attachments do
      attachments_attributes do
        [
          attributes_for(:answer_attachment),
          attributes_for(:answer_attachment)
        ]
      end
    end
  end

  factory :invalid_answer, class: Answer do
    body { nil }
    question
    user
  end
end
