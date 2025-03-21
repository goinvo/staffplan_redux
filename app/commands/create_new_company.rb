class CreateNewCompany

  attr_reader :company_name, :email, :user, :registration_id, :company, :user

  def initialize(company_name:, email:, name:, registration_id:)
    @company_name = company_name
    @email = email
    @name = name
    @registration_id = registration_id
  end

  def call
    create_company_record
    add_initial_owner
    enqueue_create_stripe_customer_job
    claim_registration

    @company
  end

  private

  def create_company_record
    @company = Company.create(name: @company_name)
  end

  def add_initial_owner
    @user = AddUserToCompany.new(
      email: @email,
      name: @name,
      company: @company,
      role: "owner",
      creating_new_company: true
    ).call
  end

  def enqueue_create_stripe_customer_job
    Stripe::CreateCustomerJob.perform_later(@company)
  end

  def claim_registration
    Registration.find_by!(id: @registration_id).update!(
      user: @user,
      registered_at: Time.current
    )
  end
end
