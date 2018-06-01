require "feature_helper"

feature "Visiting show page", %(
  In order to search for required question
  As a user
  I want to be able to visit questions index page
) do

  scenario "Renders page without questions if they aren't present" do
    visit questions_path
    expect(page).to have_content "Nobody has asked anything yet!"
  end

  scenario "Renders list of questions titles if they present" do
    questions = create_list(:question, 10)
    visit questions_path
    questions.each { |question| expect(page).to have_content question.title }
  end
end
