require 'faker'

#creating user
User.destroy_all
5.times do 
  User.create(name: Faker::FunnyName.name)
end

# creating post
Post.destroy_all
5.times do 
  Post.create(body: Faker::Lorem.sentence(word_count: 3), user_id: User.all.sample.id)
end

# creating address
Address.destroy_all
User.all.each do |u|
  Address.create(street: Faker::Address.street_name, city: Faker::Address.city, country: Faker::Address.country, user_id: u.id)
end

#creating event
Event.destroy_all
5.times do 
  Event.create(title: Faker::Lorem.sentence(word_count: 3))
end

#creating events
User.all.each do |u|
  u.events.destroy_all
end

# creating event_user
User.all.each do |u|
  event = Event.all.sample
  u.events << event
  u.save
end

#creating games
Game.destroy_all
5.times do 
  Game.create(title: Faker::Lorem.sentence(word_count: 3))
end

#creating enrollments
Enrollment.destroy_all
5.times do 
  Enrollment.create(user_id: User.all.sample.id, game_id: Game.all.sample.id)
end

#creating comments
Comment.destroy_all
User.all.each do |u|
  u.comments.create({body: Faker::Lorem.sentence(word_count: 3) })
end


Game.all.each do |g|
  g.comments.create({body: Faker::Lorem.sentence(word_count: 3) })
end


