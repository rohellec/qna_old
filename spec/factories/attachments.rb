FactoryBot.define do
  factory :attachment do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/test.png")) }

    factory :question_attachment do
      association :attachable, factory: :question
    end

    factory :answer_attachment do
      association :attachable, factory: :answer
    end
  end
end
