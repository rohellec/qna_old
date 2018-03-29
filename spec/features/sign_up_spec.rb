require "rails_helper"

feature "Signing up", %(
  In order to be able to sign in
  As a user
  I want to be able to sign up
) do

  given(:user) { create(:user) }

  scenario "Non-registered user is signing up" do
    visit sign_up_path
    fill_in :email
    fill_in :password
    fill_in :password_confirmation
    click_on "Sign up"

    expect(page).to have_content("Email was sent")
    expect(last_email.to).to include(user.email)
  end

  feature "After confirmation email was sent" do
    scenario "Clicking activation link inside email body" do
      token = last_email.body.match(/confirmation_token=[^"]+/)
      url = "/users/confirmation?#{token}"
      visit url

      expect(page).to have_content("Your account was succesfully confirmed")
    end

    feature "After profile is confirmed" do
      scenario "User is signing in" do
        visit sign_in_path
        fill_in :email
        fill_in :password
        click_on "Sign in"

        expect(page).to have_content("Signed in succesfully")
      end

      feature "After successfull signing in" do
        scenario "User is redirected when trying to access sign up page" do
          visit sign_up_path
          expect(page).to have_path(questions_path)
        end
      end

      scenario "Signed up user is trying to sign up twice" do
        visit sign_up_path
        fill_in :email
        fill_in :password
        fill_in :password_confirmation
        click_on "Sign up"

        expect(page).to have_content("This email is already taken")
      end
    end
  end
end
