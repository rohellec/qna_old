FactoryBot.define do
  factory :attachment do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/test.png")) }
    question
  end
end
