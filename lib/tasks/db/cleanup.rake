namespace :db do
  desc 'populates cweek and year for all work_weeks'
  task :populate_cweek_and_year => :environment do
    query = WorkWeek.where(cweek: nil).where(year: nil)
    puts "Populating cweek/year on #{query.count} work weeks..."
    
    query.all.each_with_index do |work_week, index|
      date = Time.at(work_week.beginning_of_week / 1000).to_date
      work_week.update_attributes(cweek: date.cweek, year: date.year)
      puts "\tupdated #{index} work weeks..." if index % 500 == 0 && index > 0
    end
  end
  
  desc 'reset dev environment from current staffplan production database'
  task :full_reset => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    
    Bundler.with_clean_env {
      %x{heroku pg:transfer --to postgres://localhost/staffplan_redux_development --app staffplan --confirm staffplan}
    }
    
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:stagify'].invoke
    Rake::Task['db:populate_cweek_and_year'].invoke
  end
  
  desc 'obfuscate user emails, reset passwords and confirm the users for devise'
  task :stagify => :environment do
    User.all.each { |user|
      user.assign_attributes(password: "password", password_confirmation: "password")
      user.skip_confirmation!
      user.save!
    }
  end
end
