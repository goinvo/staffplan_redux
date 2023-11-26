FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }

    after(:build) do |user, options|
      # a current company is required for the user to be valid
      # unless one is already set, create one
      next if user.current_company.present?

      company = create(:company)
      build(:membership, user: user, company: company)
      user.current_company = company
    end
  end

  factory :company do
    name { Faker::Company.name }
  end

  factory :membership do
    company
    user
    status { 'active' }
    role { 'owner' }
  end

  factory :client do
    company
    name { Faker::Company.name }
    status { 'active' }
  end

  factory :project do
    client
    name { Faker::Company.name }
    status { 'active' }
    cost { Faker::Number.decimal(l_digits: 2) }
    payment_frequency { 'monthly' }
  end

  factory :assignment do
    user
    project
    status { 'active' }
  end

  factory :work_week do
    assignment
    cweek { Date.today.cweek }
    year { Date.today.year }
    beginning_of_week { Date.today.beginning_of_week.to_datetime.to_i }
    estimated_hours { rand(2..8) }
    actual_hours { rand(2..8) }
  end
end
