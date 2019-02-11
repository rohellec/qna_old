require "feature_helper"

feature "Creating comment", %(
  In order to discuss question
  As authenticated user
  I want to be able to add a comment
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }
  given(:comment_attributes) { attributes_for(:comment) }

  context "when authenticated", js: true do
    background do
      sign_in user
      visit question_path(question)
    end

    describe "clicking 'Add comment' link" do
      background { click_on "Add comment" }

      scenario "new comment form is rendered" do
        expect(page).to have_css    "form.new-comment"
        expect(page).to have_button "Save Comment"
      end

      scenario "'Cancel' link appears instead of 'Add comment'" do
        expect(page).to have_link "Cancel"
        expect(page).to have_no_link "Add comment"
      end

      describe "and clicking 'Cancel link after that'" do
        background { click_on "Cancel" }

        scenario "hides new comment form" do
          expect(page).to have_no_css    "form.new-comment"
          expect(page).to have_no_button "Save Comment"
        end

        scenario "'Add comment' link becomes visible" do
          expect(page).to have_link "Add comment"
          expect(page).to have_no_link "Cancel"
        end
      end
    end

    context "when filling comment's body" do
      background { add_comment_to(question, comment_attributes) }

      scenario "new comment is created" do
        expect(page).to have_content comment_attributes[:body]
        expect(page).to have_content "Your comment has been successfully created"
        expect(page).to have_no_css  "form.new-comment"
      end
    end

    context "without filling comment's body" do
      background do
        click_on "Add comment"
        click_on "Save Comment"
      end

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

  context "when using different sessions", js: true do
    scenario "comment appears on guest's question page" do
      Capybara.using_session(:guest) do
        visit question_path(question)
      end

      Capybara.using_session(:author) do
        sign_in(user)
        visit question_path(question)
        add_comment_to(question, comment_attributes)
        within "#question-#{question.id}" do
          expect(page).to have_content comment_attributes[:body], count: 1
        end
      end

      Capybara.using_session(:guest) do
        within "#question-#{question.id}" do
          expect(page).to have_content comment_attributes[:body]
        end
      end
    end
  end
end
