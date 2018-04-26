require "rails_helper"

feature "Updating answer", %(
  In order to fix errors inside answers
  As answer's author
  I want to be able to update answer
) do

  given(:question) { create(:question) }
  given(:answer)   { create(:answer, question: question) }

  context "when authenticated" do
    given(:user) { create(:confirmed_user) }

    before { sign_in user }

    context "when author" do
      given(:user_answer) { create(:answer, question: question, user: user) }

      background { visit question_path(question) }

      describe "filling answer's body" do

        background do
          within ".answers" do
            click_on "Edit"
          end
        end

        context "with empty string" do
          background do
            fill_in :answer_body, with: ""
            click_on "Update"
          end

          scenario "Question page is rendered with error" do
            expect(page).to have_content "Body can't be blank"
          end

          scenario "Answer still has its initial content" do
            # 'find' causes capybara to wait until '#errors' div is shown on the page
            # which means that js execution is finished.
            # Without 'find' capybara won't wait, and content on index page isn't updated
            find "#errors"
            page.reload
            expect(page).to have_content user_answer.body
          end
        end

        context "with updated content" do
          background do
            fill_in :answer_body, with: "Updated answer"
            click_on "Update"
          end

          scenario "Question page is rendered with updated content" do
            expect(page).to have_content "Updated answer"
            expect(page).to have_no_css "form#edit-answer-#{answer.id}"
          end
        end
      end
    end
  end
end
