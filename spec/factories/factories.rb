FactoryGirl.define do

  factory :user do
    sequence(:email)          { |n| "test-#{n}@example.com" }
    password                  "password123"
    password_confirmation     "password123"
    sequence(:first_name)     { |n| "First#{n}" }
    sequence(:last_name)      { |n| "Last#{n}" }
  end

  factory :confirmed_user, :parent => :user do
    after(:create) { |user| user.confirm! }
  end

  factory :company do
    sequence(:name)           { |n| "company#{n}" }
  end

  factory :membership do
    user
    company
  end

  factory :client do
    company
    sequence(:name)           { |n| "client#{n}" }
    description               "A really great client to have."
  end

  factory :project do
    client
    company
    name                      { |n| "project#{n}" }
  end

end
