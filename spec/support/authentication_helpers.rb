module Helpers
  module Authentication
    def sign_in_as(user)
      visit root_path

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_link "Sign In"
    end
  end
end
