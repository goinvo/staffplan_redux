require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  describe "POST #create" do
    it "does not raise an error if called with missing params" do
      post :create, params: { }
      assert_equal "Sorry, please try that again.", flash[:alert]
    end
  end
end