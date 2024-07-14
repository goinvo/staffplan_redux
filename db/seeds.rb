# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

acme = Company.find_or_create_by(name: "Acme Co.")

if acme.users.none?
  AddUserToCompany.new(
    email: "owner@acme.co",
    name: "Acme Owner",
    role: "owner",
    company: acme
  ).call

  AddUserToCompany.new(
    email: "admin@acme.co",
    name: "Acme Admin",
    role: "admin",
    company: acme
  ).call

  AddUserToCompany.new(
    email: "member@acme.co",
    name: "Acme Member",
    role: "member",
    company: acme
  ).call

  acme.save!
else
  puts "Found users for Acme Co., skipping..."
end

if acme.clients.none?
  5.times do
    acme.clients.create(name: Faker::Company.name)
  end

  acme.clients.each do |client|
    next if client.projects.any?
    7.times do
      client.projects.create(
        name: Faker::Company.name,
        cost: Faker::Number.decimal(l_digits: 2),
        payment_frequency: "monthly",
        status: Project::CONFIRMED
      )
    end

    acme.users.each do |user|
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
  puts "Found clients for Acme Co., skipping clients and projects..."
end
