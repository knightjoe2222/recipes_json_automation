desc "This task is called by the Heroku scheduler add-on"
task :import_pictures => :environment do
  puts "Starting Recipe.import_pictures..."
  Recipe.import_pictures
  puts "done."
end