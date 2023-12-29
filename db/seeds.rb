# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

goinvo = Company.find_or_create_by(name: "GoInvo")
emails = ENV["STAFF_PLAN_EMAILS"].split(",").map(&:strip)

if goinvo.users.none?
  emails.each do |email|
    AddUserToCompany.new(
      email:,
      name: Faker::Name.name,
      company: goinvo
    ).call
  end

  goinvo.save!
else
  puts "Found users for GoInvo, skipping..."
end

if goinvo.clients.none?
  5.times do
    goinvo.clients.create(name: Faker::Company.name)
  end

  goinvo.clients.each do |client|
    next if client.projects.any?
    7.times do
      client.projects.create(
        name: Faker::Company.name,
        cost: Faker::Number.decimal(l_digits: 2),
        payment_frequency: "monthly",
        status: Project::ACTIVE
      )
    end

    goinvo.users.each do |user|
      client.projects.sample(2).each do |project|
        Assignment.create!(
          user: user,
          project: project,
          status: Assignment::ACTIVE
        )
      end
    end
  end
else
  puts "Found clients for GoInvo, skipping clients and projects..."
end
