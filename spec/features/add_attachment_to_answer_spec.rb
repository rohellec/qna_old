require "feature_helper"

feature "Adding attachment to question", %(
  In order to better explain an answer
  As answer's author
  I want to be able to attach file to answer
), js: true do

  given(:user) { create(:confirmed_user) }
  given(:question) { create(:question) }
  given(:answer_attributes) { attributes_for(:answer, user: user) }

  background do
    sign_in user
    visit question_path(question)
    fill_in :answer_body, with: answer_attributes[:body]
  end

  describe "Submitting form without attachment" do
    background do
      click_on "Create Answer"
    end

    scenario "doesn't add any attachment to the created question" do
      expect(page).to have_content "New answer has been successfully created"
      expect(page).to have_no_css  ".answer-attachments"
    end
  end

  describe "Submitting form with one attachment" do
    background do
      attach_file 'File', Rails.root.join("spec/fixtures/test.png")
      click_on "Create Answer"
    end

    scenario "adds file to the created answer" do
      expect(page).to have_content "New answer has been successfully created"
      within ".answer-attachments" do
        expect(page).to have_link "test.png",
                                  href: "/uploads/attachment/file/#{last_attachment.id}/test.png"
      end
    end
  end
end
