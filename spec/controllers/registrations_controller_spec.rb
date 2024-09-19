require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe "POST #create" do
    it "does not raise an error if called with missing params" do
      expect {
        post :create, params: {  }
      }.not_to raise_error

      expect(flash[:alert]).to eq("Sorry, please try that again.")
    end
  end
end
