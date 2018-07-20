require "feature_helper"

feature "Edit question's attachment", %(
  In order to update question's explanation
  As a question's author
  I want to be able to change question's attachment
) do

  given(:user) { create(:confirmed_user) }
  given(:question) { create(:question_with_attachment, user: user) }

  background { sign_in user }

  describe "from question Edit page" do
    background do
      visit edit_question_path(question)
      attach_file 'test', Rails.root.join("spec/fixtures/test2.png")
    end

    scenario "changing attachment will change it's label", js: true do
      within ".attachments_fields" do
        expect(page).to have_content "test2"
      end
    end

    scenario "submitting form with new attachment updates file on question" do
      click_on "Update Question"
      expect(page).to have_content "Question has been successfully updated"
      expect(page).to have_link "test2.png",
                                href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
    end
  end

  describe "from question Show page" do
    background do
      visit question_path(question)
      click_on "Edit"
      attach_file 'test', Rails.root.join("spec/fixtures/test2.png")
    end

    scenario "changing attachment will change it's label", js: true do
      within ".attachments_fields" do
        expect(page).to have_content "test2"
      end
    end

    scenario "submitting form with new attachment updates file on question" do
      click_on "Update Question"
      expect(page).to have_content "Question has been successfully updated"
      expect(page).to have_link "test2.png",
                                href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
    end
  end
end
