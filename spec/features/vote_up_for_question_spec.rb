require "feature_helper"

feature "Voting up for question", %(
  In order to show that question is useful
  As authenticated user
  I want to be able to vote up for question
) do

  given(:user) { create(:confirmed_user) }

  context "when authenticated" do
    background do
      sign_in user
      question_path(question)
      click_on "Up vote"
    end

    context "when is author" do
      given(:question) { create(:question, user: user) }

      scenario "voting is forbidden" do
        expect(page).to have_content "You can't vote for your own question"
        within ".question-rating" do
          expect(page).to have_content 0
        end
      end
    end

    context "when is not author" do
      given(:question) { create(:question) }

      scenario "voting up for question raises question's rating" do
        within ".question-rating" do
          expect(page).to have_content 1
        end
      end

      scenario "after voting up 'Up vote' link is disabled" do
        within ".question-rating" do
          expect(page).to have_content 1
        end
      end
    end
  end

  context "when non-authenticated" do
    background do
      visit question_path(question)
      click_on "Up vote"
    end

    scenario "reditects to new_user_session_path" do
      expect(page).to have_current_path new_user_session_path
    end
  end
end
