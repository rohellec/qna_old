require "rails_helper"

feature "Creating answer", %(
  In order to help other community users
  As an authenticated user
  I want to be able to create answers
) do

  given(:question) { create(:question) }

  context "For authenticated user" do
    given(:user) { create(:confirmed_user) }

    background do
      sign_in user
      visit question_path(question)
    end

    scenario "'New answer' form is rendered on the question's page" do
      expect(page).to have_content question.body
      expect(page).to have_css "form#new_answer"
    end

    context "without filling answer's mandatory fields" do
      background { click_on "Create Answer" }

      scenario "question's page is rendered with errors" do
        expect(page).to have_content question.body
        expect(page).to have_css ".alert", text: "error"
      end
    end

    context "filling all mandatory fields" do
      given(:answer_attributes) { attributes_for(:answer) }

      background do
        fill_in :answer_body, with: answer_attributes[:body]
        click_on "Create Answer"
      end

      scenario "Question's page is rendered with new answer added" do
        expect(page).to have_content question.body
        expect(page).to have_content answer_attributes[:body]
        expect(page).to have_content "successfully created"
      end
    end
  end

  context "For non-authenticated user" do
    scenario "'New Answer' form is not visible on the question's page" do
      visit question_path(question)
      expect(page).to have_no_css "form#new_answer"
    end
  end
end
