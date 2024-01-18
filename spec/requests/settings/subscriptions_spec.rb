require 'rails_helper'

RSpec.describe "Settings::Subscriptions", type: :request, vcr: true do
  before do
    Sidekiq::Testing.inline!
  end

  describe "creating a new subscription" do
    it "generates a URL to Stripe and redirects the user to Stripe" do
      registration = create(:registration, name: "Static Name", email: "static@email.com")
      registration.register!
      user = registration.user
      passwordless_sign_in(user)

      get new_settings_subscription_path

      expect(response).to redirect_to("https://checkout.stripe.com/c/pay/cs_test_a1HrFHAruJKtNgRtb7C5itrE9SFyWzJ9D0AwuObBVqzgIu5DodQdrIc8cA#fid2cGd2ZndsdXFsamtQa2x0cGBrYHZ2QGtkZ2lgYSc%2FY2RpdmApJ2R1bE5gfCc%2FJ3VuWnFgdnFaMDRKVm11bUdJb3xIZmJkZlRAYDF8V3NhPWFzXFVzV3VPR0RsXHZfcTJXXEw9U0p8VDNgUE1%2FS0tRX3xTTDQyPGNtNUBzV01fV1FXUTE2bGBxd2Izc05Ka0E1NUltTDZtbDdzJyknY3dqaFZgd3Ngdyc%2FcXdwYCknaWR8anBxUXx1YCc%2FJ3Zsa2JpYFpscWBoJyknYGtkZ2lgVWlkZmBtamlhYHd2Jz9xd3BgeCUl")
    end
  end
end
