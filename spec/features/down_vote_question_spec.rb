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
        expect(page).to have_content I18n.t("controllers.voted.votable_author_error",
                                            votable_type: "question")
        within ".question-vote .vote-rating" do
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
        expect(page).to have_content I18n.t("controllers.voted.down_vote")
        within ".question-vote .vote-rating" do
          expect(page).to have_content(-1)
        end
      end

      scenario "'delete vote' link is shown instead of 'down vote'" do
        within ".question-vote" do
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
      expect(page).to have_content I18n.t("controllers.voted.not_authenticated_error")
      within ".question-vote .vote-rating" do
        expect(page).to have_content 0
      end
    end
  end
end
