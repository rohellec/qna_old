require "rails_helper"

feature "Update question", %(
  In order to add new details to question
  As a question's author
  I want to be able to update question
) do


  context "when authenticated" do
    given(:user) { create(:confirmed_user) }

    background { sign_in user }

    context "when author" do
      given(:user_question)  { create(:question, user: user) }
      given(:other_question) { create(:question) }

      background do
        visit questions_path
        click_on "Edit"
      end

      context "with empty mandatory fields" do
        background do
          fill_in :question_title, with: ""
          fill_in :question_body,  with: ""
          click_on "Update"
        end

        scenario "'Edit Question' page is rendered with errors" do
          expect(page).to have_content "Body can't be blank"
        end

        scenario "Question still have its initial content" do
          click_on "Back"
          expect(page).to have_current_path questions_path
          expect(page).to have_content user_question.title
          expect(page).to have_content user_question.body
        end
      end

      context "with new content" do
        background do
          fill_in :question_title, with: "Updated title"
          fill_in :question_body,  with: "Updated body"
          click_on "Update"
        end

        scenario "Question page is rendered with updated content" do
          expect(page).to have_current_path user_question
          expect(page).to have_content "Updated title"
          expect(page).to have_content "Updated body"
        end
      end
    end
  end
end

