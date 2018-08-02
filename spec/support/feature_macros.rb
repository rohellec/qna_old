require "pathname"

module FeatureMacros
  def log_in(user)
    visit new_user_session_path
    fill_in :user_email,    with: user.email
    fill_in :user_password, with: user.password
    click_on "Log in"
  end

  def add_attachment(attachment, label = "File")
    click_on "Add Attachment"
    attach_file label, Rails.root.join("spec/fixtures/#{attachment}")
  end
end
