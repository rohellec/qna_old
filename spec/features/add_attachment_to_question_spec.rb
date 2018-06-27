require "feature_helper"

feature "Adding attachment question", %(
  In order to better explain a question
  As a question's author
  I want to be able to attach file to question
) do

  given!(:user) { create(:confirmed_user) }
  given(:question_attributes) { attributes_for(:question, user: user) }

  background do
    sign_in user
    visit new_question_path
    fill_in :question_title, with: question_attributes[:title]
    fill_in :question_body,  with: question_attributes[:body]
  end

  describe "Submitting form without attachment" do
    background do
      click_on "Create Question"
    end

    scenario "doesn't add any attachment to the created question" do
      expect(page).to have_content "New question has been successfully created"
      expect(page).to have_no_css  ".attachments"
    end
  end

  describe "Submitting form with one attachment" do
    background do
      attach_file 'File', Rails.root.join("spec/fixtures/test.png")
      click_on "Create Question"
    end

    scenario "adds file to the created question" do
      expect(page).to have_content "New question has been successfully created"
      within ".attachments" do
        expect(page).to have_link "test.png", href: '/uploads/attachment/file/1/test.png'
      end
    end
  end
end
