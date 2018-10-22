require "feature_helper"

feature "Deleting comment", %(
  In order to remove unreliable comment
  As comment's author
  I want to be able to delete it
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }
  given!(:user_comment)  { create(:comment, commentable: question, user: user) }
  given!(:other_comment) { create(:comment, commentable: question) }

  context "when authenticated", js: true do
    background do
      sign_in user
      visit question_path(question)
      within(".comments") { click_on "Delete" }
    end

    scenario "user's comment is removed" do
      expect(page).to have_no_content user_comment.body
      expect(page).to have_content "Comment has been successfully deleted"
    end

    scenario "'Delete' link is not visible for other user's comment" do
      within(".comments") do
        expect(page).to have_content other_comment.body
        expect(page).to have_no_link "Delete"
      end
    end
  end

  context "when non-authenticated" do
    background { visit question_path(question) }

    scenario "'Delete' link is not visible" do
      expect(page).to have_no_link "Delete"
    end
  end
end
