require "feature_helper"

feature "Adding attachment to question", %(
  In order to better explain a question
  As a question's author
  I want to be able to attach file to question
) do

  given(:user) { create(:confirmed_user) }
  given(:question_attributes) { attributes_for(:question) }

  background { sign_in user }

  describe "Creating new question with empty attachment", js: true do
    background do
      visit new_question_path
      fill_in "question[title]", with: question_attributes[:title]
      fill_in "question[body]",  with: question_attributes[:body]
      click_on "Add Attachment"
      click_on "Create Question"
    end

    scenario "doesn't add file to the created question" do
      expect(page).to have_content "New question has been successfully created"
      expect(page).to have_no_css ".question_attachments"
    end
  end

  describe "Creating new question with several attachments", js: true do
    background do
      visit new_question_path
      fill_in "question[title]", with: question_attributes[:title]
      fill_in "question[body]",  with: question_attributes[:body]
      add_attachment("test.png")
      add_attachment("test2.png")
      click_on "Create Question"
    end

    scenario "adds files to the created question" do
      expect(page).to have_content "New question has been successfully created"
      within ".question-attachments" do
        expect(page).to have_link "test.png",
                                  href: "/uploads/attachment/file/#{second_to_last_attachment.id}/test.png"
        expect(page).to have_link "test2.png",
                                  href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
      end
    end
  end

  describe "Adding attachment to existing question", js: true do
    context "without attachments" do
      given(:question) { create(:question, user: user) }

      context "when on Edit page" do
        background do
          visit edit_question_path(question)
          add_attachment("test.png")
          click_on "Update Question"
        end

        scenario "adds attachment to the question" do
          expect(page).to have_content "Question has been successfully updated"
          expect(page).to have_link "test.png",
                                    href: "/uploads/attachment/file/#{last_attachment.id}/test.png"
        end
      end

      context "when on Show page" do
        background do
          visit question_path(question)
          click_on "Edit"
          within(".edit-question") { add_attachment("test.png") }
          click_on "Update Question"
        end

        scenario "adds attachment to the question" do
          expect(page).to have_content "Question has been successfully updated"
          expect(page).to have_link "test.png",
                                    href: "/uploads/attachment/file/#{last_attachment.id}/test.png"
        end
      end
    end

    context "with attachment" do
      given(:question) { create(:question_with_attachment, user: user) }

      context "when on Edit page" do
        background do
          visit edit_question_path(question)
          add_attachment("test2.png")
          click_on "Update Question"
        end

        scenario "adds attachment to the question" do
          expect(page).to have_content "Question has been successfully updated"
          expect(page).to have_link "test2.png",
                                    href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
        end
      end

      context "when on Show page" do
        background do
          visit question_path(question)
          click_on "Edit"
          within(".edit-question") { add_attachment("test2.png") }
          click_on "Update Question"
        end

        scenario "adds attachment to the question" do
          expect(page).to have_content "Question has been successfully updated"
          expect(page).to have_link "test2.png",
                                    href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
        end
      end
    end
  end
end
