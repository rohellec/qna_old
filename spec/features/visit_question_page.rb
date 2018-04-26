require "rails_helper"

feature "Visiting show page", %(
  In order to find answer for question
  As a user
  I want to be able to visit question page
) do

  given(:question) { create(:question) }

  background { visit question_path(question) }

  scenario "Renders question's title" do
    expect(page).to have_content question.title
  end

  scenario "Renders question's body" do
    expect(page).to have_content question.body
  end

  scenario "Renders question without answers if they aren't present" do
    expect(page).to have_content "Nobody has given any answer yet!"
  end

  scenario "Renders list of answers if they present" do
    answers = create_list(:answer, 10, question: question)
    visit question_path(question)
    answers.each { |answer| expect(page).to have_content answer.body }
  end

  context "when author" do
    given(:user) { create(:confirmed_user) }
    given(:user_question)  { create(:question, user: user) }

    background do
      sign_in user
      visit question_path(user_question)
    end

    scenario "'Edit' link is visible on question_path" do
      expect(page).to have_link "Edit"
    end

    describe "clicking on 'Edit' link", js: true do
      background { click_on "Edit" }

      scenario "'Edit Question' form becomes visible" do
        expect(page).to have_css "form.edit-question"
        expect(page).to have_no_css ".question"
      end

      scenario "'Cancel' link becomes visible" do
        expect(page).to have_link "Cancel"
        expect(page).to have_no_link "Edit"
      end

      describe "clicking on 'Cancel' link" do
        background { click_on "Cancel" }

        scenario "hides 'Edit Question' form" do
          expect(page).to have_no_content "form.edit-question"
        end

        scenario "question title and body become visible" do
          within ".question" do
            expect(page).to have_content user_question.title
            expect(page).to have_content user_question.body
          end
        end

        scenario "'Edit' link becomes visible" do
          expect(page).to have_link "Edit"
          expect(page).to have_no_link "Cancel"
        end
      end
    end
  end
end
