require "rails_helper"

feature "Visiting show page", %(
  In order to find answer for question
  As a user
  I want to be able to visit question page
) do

  given(:question) { create(:question) }

  background { visit question_path(question) }

  scenario "Renders question's title" do
    expect(page).to have_content question.title
  end

  scenario "Renders question's body" do
    expect(page).to have_content question.body
  end

  scenario "Renders question without answers if they aren't present" do
    expect(page).to have_content "Nobody has given any answer yet!"
  end

  scenario "Renders list of answers if they present" do
    answers = create_list(:answer, 10, question: question)
    visit question_path(question)
    answers.each { |answer| expect(page).to have_content answer.body }
  end
end
