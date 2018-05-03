require "rails_helper"

feature "Edit question", %(
  In order to update question
  As question's author
  I want to be able to edit question
) do

  given(:user) { create(:confirmed_user) }

  describe "from question page" do
    given(:user_question)  { create(:question, user: user) }
    given(:other_question) { create(:question) }

    context "when authenticated" do
      background { sign_in user }

      context "when author" do
        background { visit question_path(user_question) }

        describe "clicking on 'Edit' link", js: true do
          background { click_on "Edit" }

          scenario "'Edit Question' form becomes visible" do
            expect(page).to have_css "form.edit-question"
            expect(page).to have_no_css ".question"
          end

          scenario "'Cancel' link becomes visible" do
            expect(page).to have_link "Cancel"
            expect(page).to have_no_link "Edit"
          end

          describe "clicking on 'Cancel' link" do
            background { click_on "Cancel" }

            scenario "hides 'Edit Question' form" do
              expect(page).to have_no_css "form.edit-question"
            end

            scenario "question title and body become visible" do
              within ".question" do
                expect(page).to have_content user_question.title
                expect(page).to have_content user_question.body
              end
            end

            scenario "'Edit' link becomes visible" do
              expect(page).to have_link "Edit"
              expect(page).to have_no_link "Cancel"
            end
          end
        end
      end

      context "when is not author" do
        scenario "'Edit' link is not visible" do
          visit question_path(other_question)
          expect(page).to have_no_link "Edit"
        end
      end
    end

    context "when non-authenticated" do
      scenario "'Edit' link is not visible" do
        visit question_path(user_question)
        expect(page).to have_no_link "Edit"
      end
    end
  end

  describe "from questions page" do
    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        given!(:user_question) { create(:question, user: user) }

        background { visit questions_path }

        describe "clicking on 'Edit' link" do
          before { click_on "Edit" }

          scenario "'Edit Question' page is rendered" do
            expect(page).to have_current_path edit_question_path(user_question)
          end
        end
      end

      context "when is not author" do
        given!(:question) { create(:question) }

        background { visit questions_path }

        scenario "'Edit' link is not visible" do
          expect(page).to have_no_link "Edit"
        end

        scenario "is redirected when trying to access edit_question_path" do
          visit edit_question_path(question)
          expect(page).to have_current_path root_path
        end
      end
    end

    context "when non-authenticated" do
      given!(:question) { create(:question) }

      background { visit questions_path }

      scenario "'Edit' link is not visible" do
        expect(page).to have_no_link "Edit"
      end

      scenario "is redirected when trying to access edit_question_path" do
        visit edit_question_path(question)
        expect(page).to have_current_path new_user_session_path
      end
    end
  end
end
