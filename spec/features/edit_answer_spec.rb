require "rails_helper"

feature "Edit question", %(
  In order to update question
  As question's author
  I want to be able to edit question
) do

  given(:user) { create(:confirmed_user) }
  given(:question) { create(:question) }

  context "when authenticated" do
    background { sign_in user }

    context "when author" do
      given!(:user_answer)  { create(:answer, question: question, user: user) }

      background { visit question_path(question) }

      describe "clicking on 'Edit' link", js: true do
        background do
          within ".answers" do
            click_on "Edit"
          end
        end

        scenario "'Edit Question' form becomes visible" do
          expect(page).to have_css "form.edit-answer"
        end

        scenario "'Cancel' link becomes visible" do
          within ".answers" do
            expect(page).to have_link "Cancel"
            expect(page).to have_no_link "Edit"
          end
        end

        describe "clicking on 'Cancel' link" do
          background { click_on "Cancel" }

          scenario "hides 'Edit Answer' form" do
            expect(page).to have_no_css "form.edit-answer"
          end

          scenario "answer body becomes visible" do
            within ".answers" do
              expect(page).to have_selector "p", text: user_answer.body
            end
          end

          scenario "'Edit' link becomes visible" do
            within ".answers" do
              expect(page).to have_link "Edit"
              expect(page).to have_no_link "Cancel"
            end
          end
        end
      end
    end

    context "when is not author" do
      given!(:answer) { create(:answer, question: question) }

      scenario "'Edit' link is not visible" do
        visit question_path(question)
        within ".answers" do
          expect(page).to have_no_content "Edit"
        end
      end
    end
  end

  context "when non-authenticated" do
    given!(:answer) { create(:answer, question: question) }

    scenario "'Edit' link is not visible" do
      visit question_path(question)
      within ".answers" do
        expect(page).to have_no_content "Edit"
      end
    end
  end
end
