namespace :db do
  desc 'populates cweek and year for all work_weeks'
  task :add_date_data => :environment do
    query = WorkWeek.where(cweek: nil).where(year: nil)
    puts "updating #{query.count} records"
    
    query.all.each_with_index do |work_week, index|
      date = Time.at(work_week.beginning_of_week / 1000).to_date
      work_week.update_attributes(cweek: date.cweek, year: date.year)
      puts "updated #{index}" if index % 500 == 0 && index > 0
    end
  end
end
