require "feature_helper"

feature "Edit comment", %(
  In order to update comment
  As comment's author
  I want to be able to edit comment
) do

  given(:user) { create(:confirmed_user) }
  given(:question) { create(:question) }

  context "as authenticated user" do
    background { sign_in user }

    context "when author" do
      given!(:user_comment)  { create(:question, commentable: question, user: user) }

      background { visit question_path(question) }

      describe "clicking on 'Edit' link", js: true do
        background do
          within(".comments") { click_on "Edit" }
        end

        scenario "'Edit comment' form becomes visible" do
          expect(page).to have_css "form.edit-comment"
        end

        scenario "'Cancel' link becomes visible" do
          within ".comments" do
            expect(page).to have_link "Cancel"
            expect(page).to have_no_link "Edit"
          end
        end

        describe "clicking on 'Cancel' link" do
          background { click_on "Cancel" }

          scenario "hides 'Edit comment' form" do
            expect(page).to have_no_css "form.edit-comment"
          end

          scenario "comment's body becomes visible" do
            within ".comments" do
              expect(page).to have_selector "p", text: user_comment.body
            end
          end

          scenario "'Edit' link becomes visible" do
            within ".comments" do
              expect(page).to have_link "Edit"
              expect(page).to have_no_link "Cancel"
            end
          end
        end
      end
    end

    context "when is not an author" do
      given!(:comment) { create(:comment, commentable: question) }

      scenario "'Edit' link is not visible" do
        visit question_path(question)
        within ".comments" do
          expect(page).to have_no_link "Edit"
        end
      end
    end
  end

  context "when non-authenticated" do
    given!(:comment) { create(:comment, commentable: question) }

    scenario "'Edit' link is not visible" do
      visit question_path(question)
      within ".comments" do
        expect(page).to have_no_link "Edit"
      end
    end
  end
end
