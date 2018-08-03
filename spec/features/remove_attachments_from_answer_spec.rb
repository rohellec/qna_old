require "feature_helper"

feature "Removing attachment from answer", %(
  In order to update answer's explanation
  As an answer's author
  I want to be able to remove attachment from answer
) do

  given(:user)     { create(:confirmed_user) }
  given(:question) { create(:question) }

  background { sign_in user }

  context "when removing the last attachment", js: true do
    given!(:answer) { create(:answer_with_attachment, question: question, user: user) }

    background do
      visit question_path(question)
      within ".answers" do
        click_on "Edit"
        click_on "Remove Attachment"
        click_on "Update Answer"
      end
    end

    scenario "question attachments are empty" do
      expect(page).to have_content "Answer has been successfully updated"
      expect(page).to have_no_css ".answer-attachments"
    end
  end

  context "when removing one of existing attachments", js: true do
    given!(:answer) { create(:answer_with_attachments, question: question, user: user) }
    given(:attachment_id) { last_attachment.id }

    background do
      visit question_path(question)
      within ".answers" do
        click_on "Edit"
        find("a[data-attachment-id='#{attachment_id}']", text: "Remove Attachment").click
        click_on "Update Answer"
      end
    end

    scenario "it is deleted from answer" do
      expect(page).to have_content "Answer has been successfully updated"
      expect(page).to have_css     ".answer-attachments"
      expect(page).to have_no_css  "#attachment-#{attachment_id}"
    end
  end
end
