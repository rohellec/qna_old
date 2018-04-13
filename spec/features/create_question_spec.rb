require "rails_helper"

feature "Creating question", %(
  In order to get help from community
  As an authenticated user
  I want to be able to create questions
) do

  context "For authenticated user" do
    given(:user) { create(:confirmed_user) }

    background do
      sign_in user
      visit questions_path
      click_on "New Question"
    end

    context "without filling mandatory fields" do
      background { click_on "Create Question" }

      scenario "'New Question' page is rendered with errors" do
        expect(page).to have_content "New Question"
        expect(page).to have_css ".alert", text: "error"
      end
    end

    context "filling all mandatory fields" do
      given(:question_attributes) { attributes_for(:question) }

      background do
        fill_in :question_title, with: question_attributes[:title]
        fill_in :question_body,  with: question_attributes[:body]
        click_on "Create Question"
      end

      scenario "redirects to question_path" do
        expect(page).to have_content question_attributes[:body]
        expect(page).to have_content "New question has been successfully created"
      end
    end
  end

  context "For non-authenticated user" do
    scenario "'New Question' link is not visible on the question's page" do
      visit questions_path
      expect(page).not_to have_content "New Question"
    end

    scenario "redirects while trying to access new_question_path" do
      visit new_question_path
      expect(page).to have_current_path new_user_session_path
    end
  end
end
