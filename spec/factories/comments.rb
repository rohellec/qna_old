FactoryBot.define do
  sequence(:comment_body) { |n| "Comment text #{n}" }

  factory :comment do
    association :commentable
    body { generate(:comment_body) }
    user
  end

  factory :invalid_comment, class: Comment do
    association :commentable
    body nil
    user
  end
end
