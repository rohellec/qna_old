require "feature_helper"

feature "Voting down the answer", %(
  In order to show that answer is noxious
  As authenticated user
  I want to be able to down vote this answer
), js: true do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }

  context "when authenticated" do
    background { sign_in user }

    context "when is author" do
      given!(:answer) { create(:answer, question: question, user: user) }

      background do
        visit question_path(question)
        within "#answer-#{answer.id}" do
          click_on "down vote"
        end
      end

      scenario "clicking 'down vote' link doesn't decrease vote rating" do
        expect(page).to have_content I18n.t("controllers.voted.votable_author_error",
                                            votable_type: "answer")
        within "#answer-#{answer.id} .vote-rating" do
          expect(page).to have_content 0
        end
      end
    end

    context "when is not author" do
      given!(:answer) { create(:answer, question: question) }

      background do
        visit question_path(question)
        within "#answer-#{answer.id}" do
          click_on "down vote"
        end
      end

      scenario "voting down decreases answer's vote rating" do
        expect(page).to have_content I18n.t("controllers.voted.down_vote")
        within "#answer-#{answer.id} .vote-rating" do
          expect(page).to have_content(-1)
        end
      end

      scenario "'delete vote' link is shown instead of 'down vote'" do
        within "#answer-#{answer.id}" do
          expect(page).to have_no_content "down vote"
          expect(page).to have_content "delete vote"
        end
      end
    end
  end

  context "when non-authenticated" do
    given!(:answer) { create(:answer, question: question) }

    background do
      visit question_path(question)
      within "#answer-#{answer.id}" do
        click_on "down vote"
      end
    end

    scenario "clicking 'down vote' link doesn't decrease vote rating" do
      expect(page).to have_content I18n.t("controllers.voted.not_authenticated_error")
      within "#answer-#{answer.id} .vote-rating" do
        expect(page).to have_content 0
      end
    end
  end
end
