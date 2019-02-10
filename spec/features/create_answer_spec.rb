require "feature_helper"

feature "Creating answer", %(
  In order to help other community users
  As an authenticated user
  I want to be able to create answers
) do

  given(:question) { create(:question) }
  given(:user)     { create(:confirmed_user) }

  context "when authenticated" do
    background do
      sign_in user
      visit question_path(question)
    end

    scenario "'New answer' form is rendered on the question's page" do
      expect(page).to have_current_path question_path(question)
      expect(page).to have_css "form.new-answer"
    end

    context "without filling answer's mandatory fields", js: true do
      background { click_on "Create Answer" }

      scenario "question's page is rendered with errors" do
        expect(page).to have_current_path question_path(question)
        expect(page).to have_content "Body can't be blank"
      end
    end

    context "filling all mandatory fields", js: true do
      given(:answer_attributes) { attributes_for(:answer) }

      background do
        create_answer(answer_attributes)
      end

      scenario "question's page is rendered with new answer added" do
        expect(page).to have_current_path question_path(question)
        expect(page).to have_content answer_attributes[:body]
        expect(page).to have_content "successfully created"
      end
    end
  end

  context "when non-authenticated" do
    scenario "'New Answer' form is not visible on the question's page" do
      visit question_path(question)
      expect(page).to have_no_css "form.new_answer"
    end
  end

  context "when using differen session", js: true do
    given(:answer_attributes) { attributes_for(:answer) }

    scenario "answer appears on guest's question page" do
      Capybara.using_session(:guest) do
        visit question_path(question)
      end

      Capybara.using_session(:author) do
        sign_in(user)
        visit question_path(question)
        create_answer(answer_attributes)
        expect(page).to have_content answer_attributes[:body]
      end

      Capybara.using_session(:guest) do
        expect(page).to have_content answer_attributes[:body], count: 1
        expect(page).to have_no_content "Nobody has given any answer yet!"
      end
    end
  end
end
