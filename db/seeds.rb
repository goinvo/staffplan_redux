# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# TODO: write a command object for this.

goinvo = Company.find_or_create_by(name: "GoInvo")

if goinvo.users.none?
  rob = User.build(name: "Rob", email: "rob@example.com", current_company: goinvo)
  juhan = User.build(name: "Juhan", email: "juhan@example.com", current_company: goinvo)
  goinvo.memberships.build(user: rob, role: "owner", status: 'active')
  goinvo.memberships.build(user: juhan, role: "owner", status: 'active')
  goinvo.save!
else
  puts "Found users for GoInvo, skipping..."
end

if goinvo.clients.none?
  design_anonymous = goinvo.clients.create(name: "Design Anonymous")
  builders_paradise = goinvo.clients.create(name: "Builder's Paradise")

  [design_anonymous, builders_paradise].each do |client|
    5.times do
      client.projects.create(
        name: Faker::Company.name,
        cost: Faker::Number.decimal(l_digits: 2),
        payment_frequency: "monthly"
      )
    end
  end
else
  puts "Found clients for GoInvo, skipping clients and projects..."
end
