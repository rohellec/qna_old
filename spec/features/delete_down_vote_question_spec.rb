require "feature_helper"

feature "Deleting question down vote", %(
  In order to revoke my down vote against question
  As authenticated user
  I want to be able to delete vote from this question
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }

  context "when authenticated" do
    background { sign_in user }

    context "when voted against question previously", js: true do
      given!(:down_vote) { create(:down_vote, votable: question, user: user) }

      background do
        visit question_path(question)
        click_on "delete vote"
      end

      scenario "deleting vote increases vote's rating" do
        expect(page).to have_content "Your vote has been successfully deleted"
        within ".question-vote .vote-rating" do
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
