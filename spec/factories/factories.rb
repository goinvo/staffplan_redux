FactoryGirl.define do

  factory :user do
    sequence(:email)            { |n| "test-#{n}@example.com" }
    password                    "password123"
    password_confirmation       "password123"
    sequence(:first_name)       { |n| "First#{n}" }
    sequence(:last_name)        { |n| "Last#{n}" }
  end

  factory :confirmed_user, :parent => :user do
    after(:create) { |user|
    user.confirm!
    if !user.company
      company = FactoryGirl.create(:company)
      company.users << user
    end
  }
  end

  factory :company do
    sequence(:name) { |n| "company#{n}"}
  end

end
