# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
cities = ["San Francisco", "Fort Collins", "Denver", "Detroit", "Boston"]
names = ["Cindy", "Lanie", "Jo", "Dortha", "Dorsey", "Faye", "Delsie", "Arica", "Alaine", "Roger", "Hildred", "Cinda", "Omar", "Vincenza", "Margherita", "Greg", "Rosalie", "Juli", "Charlena", "Bart", "Elke", "Delilah", "Marilou", "Ronda", "Laureen", "Malia", "Leena", "Delmar", "Dorthea", "Harlan", "Ammie", "Demarcus", "Jesse", "Tera", "Noel", "Pa", "Olympia", "Barabara", "Loreen", "Isidro", "Christen", "Ruthanne", "Preston", "Debra", "Micki", "Deana", "Domingo", "Kristle", "Stephnie", "Marjory"]

cities.each do |name|
  City.create(name: name)
end

2000.times do |i|
  name = names.sample
  User.create(name: name, email: "#{name}@scoutapp.com", city_id: City.order("random()").first.id)
end