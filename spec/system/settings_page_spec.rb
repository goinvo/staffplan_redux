require 'rails_helper'

RSpec.describe "Settings Page", type: :system do
  describe "loading the company settings page" do
    it "shows the settings page" do
      user = create(:membership).user
      passwordless_sign_in(user)

      visit settings_company_url
      expect(page).to have_text("General settings")
    end
  end

  describe "updating the company settings" do
    it "updates the company name" do
      membership = create(:membership)
      passwordless_sign_in(membership.user)

      visit settings_company_url
      fill_in "company[name]", with: "New Company Name"
      click_button "Save"
      expect(page).to have_text("Updates saved!")
      expect(membership.company.reload).to have_attributes(name: "New Company Name")
    end
  end
end
