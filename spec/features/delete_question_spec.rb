require "rails_helper"

feature "Deleting question", %(
  In order to remove unreliable questions
  As questions author
  I want to be able to delete them
) do

  given(:user) { create(:confirmed_user) }
  given!(:user_question)  { create(:question, user: user) }
  given!(:other_question) { create(:question) }

  describe "from questions index page", js: true do
    context "when authenticated" do
      background do
        sign_in user
        visit questions_path
        within("table") { click_on "Delete" }
      end

      scenario "user's question is removed" do
        expect(page).to have_no_content user_question.title
        expect(page).to have_content "Question has been successfully deleted"
      end

      scenario "'Delete' link is not visible for other user's question" do
        expect(page).to have_no_link "Delete"
      end
    end

    context "when non-authenticated" do
      background { visit questions_path }

      scenario "'Delete' link is not visible" do
        expect(page).to have_no_link "Delete"
      end
    end
  end

  describe "from question's show page" do
    context "when authenticated" do
      background { sign_in user }

      context "when author" do
        background do
          visit question_path(user_question)
          click_on "Delete"
        end

        scenario "redirects to questions_path" do
          expect(page).to have_current_path questions_path
        end

        scenario "user's question is removed" do
          expect(page).to have_no_content user_question.title
        end
      end

      context "when is not author" do
        background { visit question_path(other_question) }

        scenario "'Delete' link is not visible" do
          expect(page).to have_no_link "Delete"
        end
      end
    end

    context "when non-authenticated" do
      background { visit question_path(user_question) }

      scenario "'Delete' link is not visible" do
        expect(page).to have_no_link "Delete"
      end
    end
  end
end
