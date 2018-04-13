require "rails_helper"

feature "Signing in", %(
  In order to be able to ask questions
  As a user
  I want to be able to sign in
) do

  context "Non-activated user" do
    given(:user) { create(:user) }

    background { log_in user }

    scenario "is not able sign in" do
      expect(page).to have_content "You have to confirm your email"
    end

    context "after activation" do
      background do
        user.confirm
        log_in user
      end

      scenario "is able to sign in" do
        expect(page).to have_content "Signed in successfully"
      end

      context "after signing in" do
        background { click_on "Sign out" }

        scenario "is able to sign out" do
          expect(page).to have_content "Signed out successfully"
          expect(page).to have_link    "Sign in"
          expect(page).to have_no_link "Sign out"
        end
      end
    end
  end

  context "Non-signed up user" do
    given(:user) { build(:user) }

    background { log_in user }

    scenario "is not signed in" do
      expect(page).to have_content "Invalid Email or password"
    end
  end
end
