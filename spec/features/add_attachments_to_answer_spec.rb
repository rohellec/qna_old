require "feature_helper"

feature "Adding attachment to answer", %(
  In order to better explain an answer
  As answer's author
  I want to be able to attach file to answer
), js: true do

  given(:user) { create(:confirmed_user) }
  given(:question) { create(:question) }

  background { sign_in user }

  describe "Creating new answer" do
    given(:answer_attributes) { attributes_for(:answer, user: user) }

    background do
      visit question_path(question)
      fill_in :answer_body, with: answer_attributes[:body]
    end

    context "with empty attachment" do
      background do
        click_on "Add Attachment"
        click_on "Create Answer"
      end

      scenario "doesn't add file to the created answer" do
        expect(page).to have_content "New answer has been successfully created"
        expect(page).to have_no_css ".answer_attachments"
      end
    end

    context "with several attachments" do
      background do
        within(".new-answer") do
          fill_in :answer_body, with: answer_attributes[:body]
          add_attachment("test.png")
          add_attachment("test2.png")
          click_on "Create Answer"
        end
      end

      scenario "adds files to the created answer" do
        expect(page).to have_content "New answer has been successfully created"
        expect(page).to have_link "test.png",
                                  href: "/uploads/attachment/file/#{second_to_last_attachment.id}/test.png"
        expect(page).to have_link "test2.png",
                                  href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
      end
    end
  end

  describe "Adding attachment to existing answer" do
    context "without attachments" do
      given!(:answer) { create(:answer, question: question, user: user) }

      background do
        visit question_path(question)
        within ".answers-table" do
          click_on "Edit"
          add_attachment("test.png")
          click_on "Update Answer"
        end
      end

      scenario "adds attachment to the answer" do
        expect(page).to have_content "Answer has been successfully updated"
        within ".answer-attachments" do
          expect(page).to have_link "test.png",
                                    href: "/uploads/attachment/file/#{last_attachment.id}/test.png"
        end
      end
    end

    context "with attachment" do
      given!(:answer) { create(:answer_with_attachment, question: question, user: user) }

      background do
        visit question_path(question)
        within ".answers-table" do
          click_on "Edit"
          add_attachment("test2.png")
          click_on "Update Answer"
        end
      end

      scenario "adds attachment to the answer" do
        expect(page).to have_content "Answer has been successfully updated"
        within ".answer-attachments" do
          expect(page).to have_link "test2.png",
                                    href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
        end
      end
    end
  end
end
