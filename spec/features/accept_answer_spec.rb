require "feature_helper"

feature "Accepting an answer for question", %(
  In order to mark question as answered
  As a question's author
  I want to be able to accept correct answer
) do

  given!(:user) { create(:confirmed_user) }
  given!(:question) { create(:question, user: user) }
  given!(:answer_one) { create(:answer, question: question) }
  given!(:answer_two) { create(:answer, question: question) }

  context "when authenticated" do
    background { sign_in user }

    context "when author" do
      background { visit question_path(question) }

      scenario "'Accept' button is visible for answers" do
        expect(page).to have_link "Accept", count: 2
      end

      describe "after accepting one of the answers", js: true do
        background do
          within "#answer-#{answer_two.id}" do
            click_on "Accept"
          end
        end

        context "on question page" do
          scenario "question has class .answered" do
            expect(page).to have_css ".answered"
          end

          scenario "accepted answer appears on the top of other answers" do
            within ".answers" do
              # 'find' causes capybara to wait until '.accepted' answer is shown on the page
              # which means that js execution is finished.
              # Without 'find' capybara won't wait, and content within '.answers' isn't updated
              find ".accepted"
              expect(page.body.index(answer_two.body)).to be < page.body.index(answer_one.body)
            end
          end

          scenario "'Remove accept' button appears instead of 'Accept' for the accepted answer" do
            within "#answer-#{answer_two.id}" do
              expect(page).to have_link "Remove accept"
              expect(page).to have_no_link "Accept"
            end
          end

          describe "clicking 'Accept' for another answer" do
            background do
              within "#answer-#{answer_one.id}" do
                click_on "Accept"
              end
            end

            scenario "Previous accepted answer is available for accepting again" do
              within "#answer-#{answer_two.id}" do
                expect(page).to have_link "Accept"
                expect(page).to have_no_link "Remove accept"
              end
            end
          end
        end

        context "on questions page" do
          background do
            # 'find' causes capybara to wait until class '.answered' is shown on the page
            # which means that js execution is finished.
            find(".answered")
            visit questions_path
          end

          scenario "question is marked as answered" do
            within ".questions" do
              expect(page).to have_css ".answered"
            end
          end
        end
      end
    end

    context "when is not author" do
      given!(:other_question) { create(:question) }
      given!(:other_answer)   { create(:answer, question: other_question) }

      scenario "'Accept' link is not visible on question page" do
        visit question_path(other_question)
        expect(page).to have_no_link "Accept"
      end
    end
  end

  context "when non-authenticated" do
    scenario "'Accept' link is not visible on question page" do
      visit question_path(question)
      expect(page).to have_no_link "Accept"
    end
  end
end
