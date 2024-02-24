require 'rails_helper'

RSpec.describe "Settings::Subscriptions", type: :request, vcr: true do

  describe "creating a new subscription" do
    it "generates a URL to Stripe and redirects the user to Stripe" do
      registration = create(:registration, name: "Static Name", email: "static@email.com")
      registration.register!
      user = registration.reload.user
      passwordless_sign_in(user)

      get new_settings_subscription_path

      expect(response).to redirect_to /https:\/\/billing\.stripe\.com\/p\/session\/.*/
    end
  end
end
