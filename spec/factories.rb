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
end
