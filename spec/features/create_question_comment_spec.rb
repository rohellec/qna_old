require "feature_helper"

feature "Creating comment", %(
  In order to discuss question
  As authenticated user
  I want to be able to create comments
) do

  given(:question) { create(:question) }

  context "as authenticated user" do
    given(:user) { create(:confirmed_user) }

    background do
      sign_in user
      visit question_path(question)
      click_on "Add comment"
    end

    scenario "clicking 'Add comment' button renders form for new question's comment" do
      expect(page).to have_css "#new_comment"
      expect(page).to have_button "Create comment"
    end

    context "without filling mandatory fields" do
      scenario "comment's errors are rendered on the page" do
        click_on "Create comment"
        expect(page).to have_content "Body can't be blank"
      end
    end

    context "filling comment's body" do
      given(:comment_body) { attributes_for(:comment).body }

      background do
        fill_in :comment_body, with: comment_body
        click_on "Create comment"
      end

      scenario "new comment is rendered on the page" do
        expect(page).to have_content comment_body
        expect(page).to have_content "successfully created"
      end
    end
  end

  context "as non-authenticated user" do
    scenario "'Add comment' button is not visible" do
      visit question_path(question)
      expect(page).to have_no_content "Add comment"
    end
  end
end
