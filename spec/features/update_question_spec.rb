require "rails_helper"

feature "Update question", %(
  In order to add new details to question
  As a question's author
  I want to be able to update question
) do

  given(:question) { create(:question) }

  context "when authenticated" do
    given(:user) { create(:confirmed_user) }

    background { sign_in user }

    context "when author" do
      given(:user_question)  { create(:question, user: user) }

      background { visit question_path(user_question) }

      scenario "'Edit' link is visible on question_path" do
        expect(page).to have_link "Edit"
      end

      describe "filling form fields", js: true do
        background { click_on "Edit" }

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
            visit questions_path
            within ".questions" do
              expect(page).to have_content user_question.title
            end
          end
        end

        context "with new content" do
          background do
            fill_in :question_title, with: "Updated title"
            fill_in :question_body,  with: "Updated body"
            click_on "Update"
          end

          scenario "Question page is rendered with updated content" do
            expect(page).to have_current_path question_path(user_question)
            expect(page).to have_content "Updated title"
            expect(page).to have_content "Updated body"
          end

          scenario "Questions 'index' page is rendered with updated content" do
            visit questions_path
            within ".questions" do
              expect(page).to have_content "Updated title"
            end
          end
        end
      end
    end

    context "when is not author" do
      scenario "'Edit' link is visible on question_path" do
        visit question_path(question)
        expect(page).to have_no_link "Edit"
      end
    end
  end

  context "when is not authenticated" do
    scenario "'Edit' link is not visible on question_path" do
      visit question_path(question)
      expect(page).to have_no_link "Edit"
    end
  end
end
