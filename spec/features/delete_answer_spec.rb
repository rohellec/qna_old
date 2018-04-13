require "rails_helper"

feature "Deleting answer", %(
  In order to remove unreliable answers
  As answers author
  I want to be able to delete them
) do

  given(:question) { create(:question) }
  given(:user)     { create(:confirmed_user) }
  given!(:user_answer)  { create(:answer, question: question, user: user) }
  given!(:other_answer) { create(:answer, question: question) }

  context "For authenticated user" do
    background { sign_in user }

    context "from question's page" do
      background { visit question_path(question) }

      scenario "user's answer is removed" do
        find(:xpath, "//a[@href='#{answer_path(user_answer)}']", text: "Delete").click

        expect(page).to have_no_content user_answer.body
        expect(page).to have_content "Answer has been successfully deleted"
      end

      scenario "'Delete' link is not visible for other user's answer" do
        expect(page).to have_no_xpath "//a[@href='#{answer_path(other_answer)}']",
                                      text: "Delete"
      end
    end
  end

  context "For non-authenticated user" do
    context "from question's show page" do
      background { visit question_path(question) }

      scenario "'Delete' link is not visible" do
        expect(page).to have_no_content "Delete"
      end
    end
  end
end