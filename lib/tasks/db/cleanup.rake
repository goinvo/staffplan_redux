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
    puts "dropping"
    Rake::Task['db:drop'].invoke
    
    puts "creating"
    Rake::Task['db:create'].invoke
    
    puts "pulling"
    Bundler.with_clean_env {
      %x{heroku pg:transfer --to postgres://localhost/staffplan_redux_development --app staffplan --confirm staffplan}
    }
    
    puts "migrating"
    Rake::Task['db:migrate'].invoke
    
    puts "cweek and year"
    Rake::Task['db:populate_cweek_and_year'].invoke
  end
end
