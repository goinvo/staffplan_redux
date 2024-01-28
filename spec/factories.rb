FactoryBot.define do

  factory :user do
    name { Faker::Name.name + " #{rand(1..100).to_s}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }

    after(:build) do |user, _options|
      # a current company is required for the user to be valid
      # unless one is already set, create one
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
    status { Membership::ACTIVE }
    role { Membership::OWNER }

    after(:build) do |membership, _options|
      next if membership.user.blank?
      next if membership.company.blank?

      membership.user.current_company = membership.company
      membership.user.current_company_id = membership.company.id
    end
  end

  factory :client do
    company
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
    status { Client::ACTIVE }
  end

  factory :project do
    client
    name { Faker::Company.name + " #{rand(1..100).to_s}"}
    status { Project::ACTIVE }
    cost { Faker::Number.decimal(l_digits: 2) }
    payment_frequency { Project::MONTHLY }
  end

  factory :assignment do
    user
    project
    status { Assignment::ACTIVE }
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

  factory :registration do
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    expires_at { 1.week.from_now }
    ip_address { Faker::Internet.ip_v4_address }
    token { Faker::Internet.password(min_length: 10, max_length: 20) }
  end
end
