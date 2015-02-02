namespace :db do
  desc 'populates cweek and year for all work_weeks'
  task :populate_cweek_and_year => :environment do
    query = WorkWeek.where(cweek: nil).where(year: nil)
    puts "Populating cweek/year on #{query.count} work weeks..."

    query.all.each_with_index do |work_week, index|
      date = Time.at(work_week.beginning_of_week / 1000).to_date
      work_week.update_attributes(cweek: date.cweek, year: date.year)

      puts "\tupdated #{index} work weeks cweek/year..." if index % 500 == 0 && index > 0
    end

    puts "Checking beginning_of_week on #{WorkWeek.count} work weeks..."
    bow_count = 0

    WorkWeek.find_in_batches do |group|
      group.each do |work_week|
        bow_count += 1

        if work_week.beginning_of_week.to_s.length == 10
          begin
            work_week.update_attributes(beginning_of_week: work_week.beginning_of_week * 1000)
          rescue ActiveRecord::RecordNotUnique => e
            # attempt to resolve the conflict. keep the most recently updated work_week record
            other_work_week = WorkWeek.where(assignment_id: work_week.assignment_id, beginning_of_week: work_week.beginning_of_week).first

            if other_work_week.nil?
              raise "unable to find the other conflicting work week for assignment_id: #{work_week.assignment_id} and bow: #{work_week.beginning_of_week}"
            end

            if other_work_week.updated_at > work_week.updated_at
              work_week.destroy!
              other_work_week.save!
            else
              other_work_week.destroy!
              work_week.save!
            end
          end
        end

        puts "\tchecked beginning_of_week on #{bow_count} work weeks..." if bow_count % 500 == 0
      end
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
