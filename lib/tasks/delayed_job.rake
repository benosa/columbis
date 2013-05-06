namespace :dj do
  desc "Fetch new courses from cbr.ru"
  task :fetch_curses => :environment do
    CurrencyCourse.delay.get_current_courses
  end
end
