require "feature_helper"

feature "Creating question", %(
  In order to get help from community
  As an authenticated user
  I want to be able to create questions
) do

  context "when authenticated" do
    given(:user) { create(:confirmed_user) }

    background do
      sign_in user
      visit questions_path
      click_on "New Question"
    end

    scenario "'New Question' page is rendered" do
      expect(page).to have_current_path new_question_path
    end

    context "without filling mandatory fields" do
      background { click_on "Create Question" }

      scenario "'New Question' page is rendered with errors" do
        expect(page).to have_content "Body can't be blank"
      end
    end

    context "filling all mandatory fields" do
      given(:question_attributes) { attributes_for(:question) }

      background do
        create_question(question_attributes)
      end

      scenario "redirects to newly created question" do
        created_question = Question.last
        expect(page).to have_current_path question_path(created_question)
        expect(page).to have_content question_attributes[:title]
        expect(page).to have_content question_attributes[:body]
        expect(page).to have_content "New question has been successfully created"
      end
    end
  end

  context "when non-authenticated" do
    scenario "'New Question' link is not visible on the question's page" do
      visit questions_path
      expect(page).not_to have_content "New Question"
    end

    scenario "redirects while trying to access new_question_path" do
      visit new_question_path
      expect(page).to have_current_path new_user_session_path
    end
  end

  context "when using different session", js: true do
    given(:user) { create(:confirmed_user) }
    given(:question_attributes) { attributes_for(:question) }

    scenario "question appears on guest's question index page" do
      Capybara.using_session(:guest) do
        visit questions_path
      end

      Capybara.using_session(:author) do
        sign_in(user)
        visit questions_path
        click_on "New Question"
        create_question(question_attributes)

        expect(page).to have_content question_attributes[:title]
        expect(page).to have_content question_attributes[:body]
      end

      Capybara.using_session(:guest) do
        expect(page).to have_content question_attributes[:title]
        expect(page).to have_no_content "Nobody has asked anything yet"
      end
    end
  end
end
