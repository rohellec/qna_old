require "pathname"

module FeatureMacros
  def log_in(user)
    visit new_user_session_path
    fill_in :user_email,    with: user.email
    fill_in :user_password, with: user.password
    click_on "Log in"
  end

  def add_attachment(attachment)
    click_on "Add Attachment"
    attach_file "File", Rails.root.join("spec/fixtures/#{attachment}")
  end

  def add_comment_to(commentable)
    within("##{commentable.class.to_s.underscore}-#{commentable.id}") do
      click_on "Add comment"
      fill_in  "comment[body]", with: "Comment text"
      click_on "Save Comment"
    end
  end

  def create_question(attributes)
    fill_in :question_title, with: attributes[:title]
    fill_in :question_body,  with: attributes[:body]
    click_on "Create Question"
  end
end
