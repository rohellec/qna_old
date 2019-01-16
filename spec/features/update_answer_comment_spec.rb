require "feature_helper"

feature "Updating answer's comment", %(
  In order to fix errors in comment's body
  As comment's author
  I want to be able to update comment
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }
  given(:answer)   { create(:answer, question: question) }
  given!(:comment) { create(:comment, commentable: answer, user: user) }

  background do
    sign_in user
    visit question_path(question)
  end

  describe "filling comments's body", js: true do
    background do
      within(".comments") { click_on "Edit" }
    end

    context "with updated content" do
      background do
        within ".edit-comment" do
          fill_in "comment[body]", with: "Updated comment"
          click_on "Update"
        end
      end

      scenario "Comment is rendered with updated content" do
        expect(page).to have_content "Updated comment"
        expect(page).to have_no_css "form.edit-comment"
        expect(page).to have_no_content comment.body
      end
    end

    context "with empty body" do
      background do
        within ".edit-comment" do
          fill_in "comment[body]", with: ""
          click_on "Update"
        end
      end

      scenario "Question page is rendered with error" do
        expect(page).to have_content "Body can't be blank"
      end

      scenario "Comment still has its initial content" do
        # 'find' causes capybara to wait until '#errors' div is shown on the page
        # which means that js execution is finished.
        # Without 'find' capybara won't wait, and content on index page isn't updated
        find "#errors"
        expect(page).to have_content comment.body
      end
    end
  end
end
