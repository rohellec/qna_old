require "feature_helper"

feature "Creating a comment", %(
  In order to clarify the answer
  As authenticated user
  I want to be able to leave a comment
) do

  given(:question) { create(:question) }
  given!(:answer)  { create(:answer, question: question) }

  context "when authenticated" do
    given(:user) { create(:confirmed_user) }

    background do
      sign_in user
      visit question_path(question)
      within(".answers") { click_on "Add comment" }
    end

    scenario "clicking 'Add comment' button renders new comment's form" do
      expect(page).to have_css    "form.new-comment"
      expect(page).to have_button "Create comment"
    end

    context "when filling comment's body" do
      given(:comment_attributes) { attributes_for(:comment) }

      background do
        fill_in :comment_body, with: comment_attributes[:body]
        click_on "Create comment"
      end

      scenario "new comment is created" do
        expect(page).to have_content comment_attributes[:body]
        expect(page).to have_content "Comment is successfully created"
        expect(page).to have_no_css  "form.new-comment"
      end
    end

    context "without filling comment's body" do
      background { click_on "Create comment" }

      scenario "error is rendered on the page" do
        expect(page).to have_css     "form.new-comment"
        expect(page).to have_content "Body can't be blank"
      end
    end
  end

  context "when non-authenticated" do
    scenario "'Add comment' button is not visible" do
      visit question_path(question)
      expect(page).to have_no_content "Add comment"
    end
  end
end
