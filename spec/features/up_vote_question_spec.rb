require "feature_helper"

feature "Voting up the question", %(
  In order to show that question is useful
  As authenticated user
  I want to be able to up vote this question
), js: true do

  given(:user) { create(:confirmed_user) }

  context "when authenticated" do
    background { sign_in user }

    context "when is author" do
      given(:question) { create(:question, user: user) }

      background do
        visit question_path(question)
        click_on "up vote"
      end

      scenario "clicking 'up vote' link doesn't increase vote rating" do
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
        click_on "up vote"
      end

      scenario "voting up increases question's vote rating" do
        expect(page).to have_content I18n.t("controllers.voted.up_vote")
        within ".question-vote .vote-rating" do
          expect(page).to have_content 1
        end
      end

      scenario "'delete vote' link is shown instead of 'up vote'" do
        within ".question-vote" do
          expect(page).to have_no_content "up vote"
          expect(page).to have_content "delete vote"
        end
      end
    end
  end

  context "when non-authenticated" do
    given(:question) { create(:question) }

    background do
      visit question_path(question)
      click_on "up vote"
    end

    scenario "clicking 'up vote' link doesn't increase vote rating" do
      expect(page).to have_content I18n.t("controllers.voted.not_authenticated_error")
      within ".question-vote .vote-rating" do
        expect(page).to have_content 0
      end
    end
  end
end
