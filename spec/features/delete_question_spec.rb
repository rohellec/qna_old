require "rails_helper"

feature "Deleting question", %(
  In order to remove unreliable questions
  As questions author
  I want to be able to delete them
) do

  given(:user) { create(:confirmed_user) }
  given!(:user_question)  { create(:question, user: user) }
  given!(:other_question) { create(:question) }

  context "when authenticated" do
    background { sign_in user }

    describe "from questions index page", js: true do
      background do
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

    describe "from user's question page" do
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

    describe "from other user's question page" do
      background { visit question_path(other_question) }

      scenario "'Delete' link is not visible" do
        expect(page).to have_no_link "Delete"
      end
    end
  end

  context "when non-authenticated" do
    describe "from questions index page" do
      background { visit questions_path }

      scenario "'Delete' link is not visible" do
        expect(page).to have_no_link "Delete"
      end
    end

    describe "from question's show page" do
      background { visit question_path(user_question) }

      scenario "'Delete' link is not visible" do
        expect(page).to have_no_link "Delete"
      end
    end
  end
end
