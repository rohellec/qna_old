require "rails_helper"

feature "Signing in", %(
  In order to be able to ask questions
  As a user
  I want to be able to sign in
) do

  give(:user) { create(:user) }

  scenario "Activated user is signing in" do
    visit sign_in_path
    fill_in :email,    with: user.email
    fill_in :password, with: user.password
    click_on "Sign in"

    expect(page).to have_content("Signed in succesfully")
  end

  scenario "Non-existing user is trying to sign in" do
    visit sign_in_path
    fill_in :email,    with: invalid_user.email
    fill_in :password, with: invalid_user.password
    click_on "Sign in"

    expect(page).to have_content("Invalid email or password")
  end
end
