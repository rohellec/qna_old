require "feature_helper"

feature "Edit answer's attachment", %(
  In order to update answer's explanation
  As answer's author
  I want to be able to change answer's attachment
), js: true do

  given(:user)   { create(:confirmed_user) }
  given(:answer) { create(:answer_with_attachment, user: user) }

  background do
    sign_in user
    visit question_path(answer.question)
    within ".answers" do
      click_on "Edit"
      attach_file 'test', Rails.root.join("spec/fixtures/test2.png")
    end
  end

  scenario "changing attachment will change it's label" do
    within ".edit-answer .attachments_fields" do
      expect(page).to have_content "test2"
    end
  end

  scenario "submitting the form updates file on the answer" do
    click_on "Update Answer"
    expect(page).to have_content "Answer has been successfully updated"
    expect(page).to have_link "test2.png",
                              href: "/uploads/attachment/file/#{last_attachment.id}/test2.png"
  end
end
