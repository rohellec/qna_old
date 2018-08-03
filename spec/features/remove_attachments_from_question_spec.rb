require "feature_helper"

feature "Removing attachment from question", %(
  In order to update question's explanation
  As a question's author
  I want to be able to remove question from attachment
) do

  given(:user) { create(:confirmed_user) }
  given(:question) { create(:question_with_attachment, user: user) }

  background { sign_in user }

  describe "from question Edit page" do
    background do
      visit edit_question_path(question)
    end

    context "when removing the last attachment", js: true do
      background do
        click_on "Remove Attachment"
        click_on "Update Question"
      end

      scenario "question attachments are empty" do
        expect(page).to have_content "Question has been successfully updated"
        expect(page).to have_no_css ".question-attachments"
      end
    end

    context "when removing one of existing attachments", js: true do
      given(:question) { create(:question_with_attachments, user: user) }
      given(:attachment_id) { last_attachment.id }

      background do
        find("a[data-attachment-id='#{attachment_id}']", text: "Remove Attachment").click
        click_on "Update Question"
      end

      scenario "it is deleted from question" do
        expect(page).to have_content "Question has been successfully updated"
        expect(page).to have_css     ".question-attachments"
        expect(page).to have_no_css  "#attachment-#{attachment_id}"
      end
    end
  end

  describe "from question Show page", js: true do
    background do
      visit question_path(question)
      click_on "Edit"
    end

    context "when removing the last attachment" do
      background do
        within ".edit-question" do
          click_on "Remove Attachment"
        end
        click_on "Update Question"
      end

      scenario "question attachments are empty", js: true do
        expect(page).to have_content "Question has been successfully updated"
        expect(page).to have_no_css ".question-attachments"
      end
    end

    context "when removing one of existing attachments" do
      given!(:question) { create(:question_with_attachments, user: user) }
      given(:attachment_id) { last_attachment.id }

      background do
        find("a[data-attachment-id='#{attachment_id}']", text: "Remove Attachment").click
        click_on "Update Question"
      end

      scenario "it is deleted from question" do
        expect(page).to have_content "Question has been successfully updated"
        expect(page).to have_css     ".question-attachments"
        expect(page).to have_no_css  "#attachment-#{attachment_id}"
      end
    end
  end
end
