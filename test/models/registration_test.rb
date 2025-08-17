require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  describe "validations" do
    it "validates presence of company_name" do
      registration = build(:registration, company_name: nil)
      refute registration.valid?
      assert_includes registration.errors[:company_name], "can't be blank"
    end

    it "validates presence of name" do
      registration = build(:registration, name: nil)
      refute registration.valid?
      assert_includes registration.errors[:name], "can't be blank"
    end

    it "validates presence of email" do
      registration = build(:registration, email: nil)
      refute registration.valid?
      assert_includes registration.errors[:email], "can't be blank"
    end

    it "validates presence of ip_address" do
      registration = build(:registration, ip_address: nil)
      refute registration.valid?
      assert_includes registration.errors[:ip_address], "can't be blank"
    end

    describe "expired?" do
      it "returns true if expires_at is in the past" do
        registration = build(:registration, expires_at: 1.day.ago)
        assert_equal true, registration.expired?
      end

      it "returns false if expires_at is in the future" do
        registration = build(:registration, expires_at: 1.day.from_now)
        assert_equal false, registration.expired?
      end
    end

    describe "available?" do
      it "returns true if expires_at is in the future" do
        registration = build(:registration, expires_at: 1.day.from_now)
        assert_equal true, registration.available?
      end

      it "returns false if expires_at is in the past" do
        registration = build(:registration, expires_at: 1.day.ago)
        assert_equal false, registration.available?
      end
    end

    describe "register!" do
      it "raises RegistrationNotAvailableError if claimed?" do
        registration = create(:registration)
        
        job_called = false
        Stripe::CreateCustomerJob.stub :perform_later, ->(company) { job_called = true } do
          registration.register!
          assert job_called
        end

        assert_raises(Registration::RegistrationNotAvailableError) do
          registration.reload.register!
        end
      end

      it "calls CreateNewCompany" do
        registration = create(:registration)
        command_called = false
        
        CreateNewCompany.stub :new, ->(company_name:, email:, name:, registration_id:) { 
          mock_command = Minitest::Mock.new
          mock_command.expect :call, nil
          command_called = true
          mock_command
        } do
          registration.register!
          assert command_called
        end
      end
    end

    describe "registered?" do
      it "returns true if registered_at is present" do
        registration = build(:registration, registered_at: Time.current)
        assert_equal true, registration.registered?
      end

      it "returns false if registered_at is blank" do
        registration = build(:registration, registered_at: nil)
        assert_equal false, registration.registered?
      end
    end

    describe "to_param" do
      it "returns the identifier" do
        registration = create(:registration)
        assert_equal registration.identifier, registration.to_param
      end
    end
  end
end