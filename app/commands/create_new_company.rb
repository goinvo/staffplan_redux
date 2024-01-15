class CreateNewCompany

  attr_reader :registration, :company, :user

  def initialize(registration)
    @registration = registration
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
    @company = Company.create(name: "#{@registration.name}'s' Company")
  end

  def add_initial_owner
    @user = AddUserToCompany.new(
      email: @registration.email,
      name: @registration.name,
      company: @company,
      role: "owner"
    ).call
  end

  def enqueue_create_stripe_customer_job
    CreateStripeCustomerJob.perform_async(@company.id)
  end

  def claim_registration
    @registration.update(user: @user, registered_at: Time.current)
  end
end