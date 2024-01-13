FactoryBot.define do

  factory :user do
    name { Faker::Name.name + " #{rand(1..100).to_s}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }

    trait(:needs_validation) do
      validation_status { User::VALIDATION_STATUS_PENDING }
    end

    after(:build) do |user, options|
      # a current company is required for the user to be valid
      # unless one is already set, create one
      next if user.email_validation_pending?
      next if user.current_company.present?

      if user.memberships.length == 1
        user.current_company = user.memberships.first.company
        next
      else
        company = create(:company)
        user.current_company = company
      end
    end

    after(:create) do |user, options|
      create(:membership, user: user, company: user.current_company)
    end
  end

  factory :company do
    name { Faker::Company.name }
  end

  factory :membership do
    company
    user { build(:user, current_company: company) }
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
    name { Faker::Company.name + " #{rand(1..100).to_s}"}
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
    estimated_hours { rand(2..8) }
    actual_hours { rand(2..8) }

    trait :blank do
      estimated_hours { 0 }
      actual_hours { 0 }
    end
  end
end
