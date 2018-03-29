require "rails_helper"

feature "Signing out", %(
  In order to be able to finish session
  As a user
  I want to be able to sign out
) do

  scenario "Signed in user is signing out" do
    click_link "Sign out"

    expect(page).to have_content("You've successfully signed out")
    expect(page).to have_link("Sign in")
    expect(page).to have_no_link("Sign out")
  end
end
