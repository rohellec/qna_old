require "feature_helper"

feature "Removing answer acceptance for a question", %(
  In order to leave question unanswered
  As a question's author
  I want to be able to remove answer acceptance
) do

  given!(:user) { create(:confirmed_user) }
  given!(:question) { create(:question, user: user) }
  given!(:answer_one) { create(:answer, question: question) }
  given!(:answer_two) { create(:accepted_answer, question: question) }

  context "when authenticated" do
    background { sign_in user }

    context "when author" do
      background { visit question_path(question) }

      scenario "'Remove accept' button is visible for accepted answer" do
        within "#answer-#{answer_two.id}" do
          expect(page).to have_link "Remove accept"
        end
      end

      describe "after removing acceptance for the answer", js: true do
        background { click_on "Remove accept" }

        context "on question page" do
          scenario "'Accept' button appears instead of 'Remove accept' for selected answer" do
            within "#answer-#{answer_two.id}" do
              expect(page).to have_link "Accept"
              expect(page).to have_no_link "Remove accept"
            end
          end

          scenario "question isn't marked as answered" do
            expect(page).to have_no_css ".answered"
          end

          scenario "restores original answers order" do
            within ".answers" do
              # using 'have_no_link' to wait until Capybara finishes js execution
              expect(page).to have_no_link "Remove accept"
              expect(page.body.index(answer_one.body)).to be < page.body.index(answer_two.body)
            end
          end
        end

        context "on questions page" do
          background do
            # adding #sleep to wait until js finishes its execution
            sleep(0.1)
            visit questions_path
          end

          scenario "question isn't marked as answered" do
            within ".questions" do
              expect(page).to have_no_css ".answered"
            end
          end
        end
      end
    end

    context "when is not author" do
      given!(:other_question) { create(:question) }
      given!(:other_answer)   { create(:accepted_answer, question: other_question) }

      scenario "'Remove accept' link is not visible on question page" do
        visit question_path(other_question)
        expect(page).to have_no_link "Remove accept"
      end
    end
  end

  context "when non-authenticated" do
    scenario "'Remove accept' link is not visible on question page" do
      visit question_path(question)
      expect(page).to have_no_link "Remove accept"
    end
  end
end
