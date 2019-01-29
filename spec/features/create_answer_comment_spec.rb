require "feature_helper"

feature "Creating comment", %(
  In order to discuss answer
  As authenticated user
  I want to be able to add a comment
) do

  given!(:question) { create(:question) }
  given!(:answer)   { create(:answer, question: question) }

  context "when authenticated", js: true do
    given(:user) { create(:confirmed_user) }

    background do
      sign_in user
      visit question_path(question)
      within(".answers") { click_on "Add comment" }
    end

    describe "after clicking 'Add comment' link" do
      scenario "new comment form is rendered" do
        expect(page).to have_css    "form.new-comment"
        expect(page).to have_button "Save Comment"
      end

      scenario "'Cancel' link appears instead of 'Add comment'" do
        within ".answers" do
          expect(page).to have_link "Cancel"
          expect(page).to have_no_link "Add comment"
        end
      end

      describe "and clicking 'Cancel' link" do
        background { click_on "Cancel" }

        scenario "hides new comment form" do
          expect(page).to have_no_css    "form.new-comment"
          expect(page).to have_no_button "Save Comment"
        end

        scenario "'Add comment' link becomes visible" do
          within ".answers" do
            expect(page).to have_link "Add comment"
            expect(page).to have_no_link "Cancel"
          end
        end
      end
    end

    context "when filling comment's body" do
      given(:comment_body) { attributes_for(:comment)[:body] }

      background do
        fill_in "comment[body]", with: comment_body
        click_on "Save Comment"
      end

      scenario "new comment is created" do
        expect(page).to have_content comment_body
        expect(page).to have_content "Your comment has been successfully created"
        expect(page).to have_no_css  "form.new-comment"
      end
    end

    context "without filling comment's body" do
      background { click_on "Save Comment" }

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
