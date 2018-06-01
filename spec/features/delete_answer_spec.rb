require "feature_helper"

feature "Deleting answer", %(
  In order to remove unreliable answer
  As answer's author
  I want to be able to delete it
) do

  given(:question) { create(:question) }
  given(:user)     { create(:confirmed_user) }
  given!(:user_answer)  { create(:answer, question: question, user: user) }
  given!(:other_answer) { create(:answer, question: question) }

  context "when authenticated", js: true do
    background do
      sign_in user
      visit question_path(question)
      within("table") { click_on "Delete" }
    end

    scenario "user's answer is removed" do
      expect(page).to have_no_content user_answer.body
      expect(page).to have_content "Answer has been successfully deleted"
    end

    scenario "'Delete' link is not visible for other user's answer" do
      expect(page).to have_no_selector "td", text: "Delete"
    end
  end

  context "when non-authenticated" do
    background { visit question_path(question) }

    scenario "'Delete' link is not visible" do
      expect(page).to have_no_link "Delete"
    end
  end
end
