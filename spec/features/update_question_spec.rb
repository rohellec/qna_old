require "feature_helper"

feature "Update question", %(
  In order to add new details to question
  As a question's author
  I want to be able to update question
) do

  given(:user) { create(:confirmed_user) }
  given!(:user_question)  { create(:question, user: user) }

  describe "from question page", js: true do
    background do
      sign_in user
      visit question_path(user_question)
      click_on "Edit"
    end

    context "with empty mandatory fields" do
      background do
        fill_in :question_title, with: ""
        fill_in :question_body,  with: ""
        click_on "Update"
      end

      scenario "'Edit Question' page is rendered with errors" do
        expect(page).to have_content "Body can't be blank"
      end

      scenario "Question still have its initial content" do
        # 'find' causes capybara to wait until '#errors' div is shown on the page
        # which means that js execution is finished.
        # Without 'find' capybara won't wait, and content on index page isn't updated
        find("#errors")
        visit questions_path
        within ".questions" do
          expect(page).to have_content user_question.title
        end
      end
    end

    context "with new content" do
      background do
        fill_in :question_title, with: "Updated title"
        fill_in :question_body,  with: "Updated body"
        click_on "Update"
      end

      scenario "Question page is rendered with updated content" do
        expect(page).to have_current_path question_path(user_question)
        within ".question" do
          expect(page).to have_content "Updated title"
          expect(page).to have_content "Updated body"
        end
      end

      scenario "Questions 'index' page is rendered with updated content" do
        # 'find' causes capybara to wait until '.question-body' div is shown on the page
        # which means that js execution is finished.
        # Without 'find' capybara won't wait, and content on index page isn't updated
        find(".question-body")
        visit questions_path
        within ".questions" do
          expect(page).to have_content "Updated title"
        end
      end
    end
  end

  describe "from questions page" do
    background do
      sign_in user
      visit questions_path
      click_on "Edit"
    end

    context "with empty mandatory fields" do
      background do
        fill_in :question_title, with: ""
        fill_in :question_body,  with: ""
        click_on "Update"
      end

      scenario "'Edit Question' page is rendered with errors" do
        expect(page).to have_content "Body can't be blank"
      end

      scenario "Question still have its initial content" do
        visit questions_path
        within ".questions" do
          expect(page).to have_content user_question.title
        end
      end
    end

    context "with new content" do
      background do
        fill_in :question_title, with: "Updated title"
        fill_in :question_body,  with: "Updated body"
        click_on "Update"
      end

      scenario "Question page is rendered with updated content" do
        expect(page).to have_current_path question_path(user_question)
        within ".question" do
          expect(page).to have_content "Updated title"
          expect(page).to have_content "Updated body"
        end
      end

      scenario "Questions 'index' page is rendered with updated content" do
        visit questions_path
        within ".questions" do
          expect(page).to have_content "Updated title"
        end
      end
    end
  end
end
