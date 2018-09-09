require "feature_helper"

feature "Deleting question's vote", %(
  In order to revoke my vote on question
  As authenticated user
  I want to be able to delete vote from this question
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }

  context "when authenticated" do
    background { sign_in user }

    context "when question has user's up vote", js: true do
      given!(:up_vote) { create(:up_vote, votable: question, user: user) }

      background do
        visit question_path(question)
        click_on "delete vote"
      end

      scenario "deleting vote decreases vote's rating" do
        expect(page).to have_content I18n.t("controllers.voted.delete_vote")
        within ".question_#{question.id}_vote .vote-rating" do
          expect(page).to have_content 0
        end
      end
    end

    context "when question has user's down vote", js: true do
      given!(:down_vote) { create(:down_vote, votable: question, user: user) }

      background do
        visit question_path(question)
        click_on "delete vote"
      end

      scenario "deleting vote increases vote's rating" do
        expect(page).to have_content I18n.t("controllers.voted.delete_vote")
        within ".question_#{question.id}_vote .vote-rating" do
          expect(page).to have_content 0
        end
      end
    end

    context "when haven't voted against question previously" do
      background { visit question_path(question) }

      scenario "delete vote is invisible" do
        expect(page).to have_no_content "delete vote"
      end
    end
  end

  context "when non-authenticated" do
    background { visit question_path(question) }

    scenario "delete vote is invisible" do
      expect(page).to have_no_content "delete vote"
    end
  end
end
