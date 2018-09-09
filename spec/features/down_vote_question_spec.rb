require "feature_helper"

feature "Voting down the question", %(
  In order to show that question is noxious
  As authenticated user
  I want to be able to down vote this question
), js: true do

  given(:user) { create(:confirmed_user) }

  context "when authenticated" do
    background { sign_in user }

    context "when is author" do
      given(:question) { create(:question, user: user) }

      background do
        visit question_path(question)
        click_on "down vote"
      end

      scenario "clicking 'down vote' link doesn't decrease vote rating" do
        expect(page).to have_content "You can't vote on your own question"
        within ".question_#{question.id}_vote .vote-rating" do
          expect(page).to have_content 0
        end
      end
    end

    context "when is not author" do
      given(:question) { create(:question) }

      background do
        visit question_path(question)
        click_on "down vote"
      end

      scenario "voting down decreases question's vote rating" do
        expect(page).to have_content "Your vote has been counted"
        within ".question_#{question.id}_vote .vote-rating" do
          expect(page).to have_content(-1)
        end
      end

      scenario "'delete vote' link is shown instead of 'down vote'" do
        within ".question_#{question.id}_vote" do
          expect(page).to have_no_content "down vote"
          expect(page).to have_content "delete vote"
        end
      end
    end
  end

  context "when non-authenticated" do
    given(:question) { create(:question) }

    background do
      visit question_path(question)
      click_on "down vote"
    end

    scenario "clicking 'down vote' link doesn't decrease vote rating" do
      expect(page).to have_content "You need to sign in before you can vote"
      within ".question_#{question.id}_vote .vote-rating" do
        expect(page).to have_content 0
      end
    end
  end
end
