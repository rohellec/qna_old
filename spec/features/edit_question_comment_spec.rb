require "feature_helper"

feature "Edit comment", %(
  In order to update question's comment
  As comment's author
  I want to be able to edit comment
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }

  context "as authenticated user" do
    background { sign_in user }

    context "after creating a comment" do
      background do
        visit question_path(question)
        add_comment_to(question)
      end

      describe "clicking on 'Edit' link", js: true do
        background do
          within(".comments") { click_on "Edit" }
        end

        scenario "'Edit comment' form becomes visible" do
          expect(page).to have_css "form.edit-comment"
          expect(page).to have_no_css ".comment-content"
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

          scenario "comment's content becomes visible" do
            within ".comments" do
              expect(page).to have_selector ".comment-content", text: "Comment text"
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

    context "when author of existing comment" do
      given!(:user_comment)  { create(:comment, commentable: question, user: user) }

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
              expect(page).to have_selector ".comment-body", text: user_comment.body
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
