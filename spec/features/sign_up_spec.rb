require "rails_helper"

feature "Signing up", %(
  In order to be able to sign in
  As a user
  I want to be able to sign up
) do

  given(:user) { build(:user) }
  given(:last_email) { ActionMailer::Base.deliveries.last }

  describe "non-signed up user" do
    background do
      visit new_user_registration_path
      fill_in :user_email,    with: user.email
      fill_in :user_password, with: user.password
      fill_in :user_password_confirmation, with: user.password
      within(".actions") { click_on "Sign up" }
    end

    scenario "confirmation email is sent" do
      expect(page).to have_content "message with a confirmation link has been sent"
      expect(last_email.to).to include user.email
    end

    context "when following confirmation link" do
      background do
        token = last_email.body.match(/confirmation_token=[^"]+/)
        url = "/users/confirmation?#{token}"
        visit url
      end

      scenario "account is confirmed" do
        expect(page).to have_content "Your email address has been successfully confirmed"
      end

      context "when account is confirmed" do
        background { log_in user }

        scenario "user is able to sign in" do
          expect(page).to have_content "Signed in successfully"
        end

        context "when already signed in and trying to sign up" do
          scenario "user is redirected" do
            visit new_user_registration_path
            expect(page).to have_current_path root_path
          end
        end
      end
    end
  end
end
