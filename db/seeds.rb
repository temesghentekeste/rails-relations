require 'faker'

10.times do 
  
  #creating user
  User.destroy_all
  10.times do 
    User.create(name: Faker::FunnyName.name)
  end

  Post.destroy_all
  10.times do 
    Post.create(body: Faker::Lorem.sentence(word_count: 3), user_id: User.all.sample.id)
  end

  Address.destroy_all
  User.all.each do |u|
    Address.create(street: Faker::Address.street_name, city: Faker::Address.city, country: Faker::Address.country, user_id: u.id)
  end

   #creating event
   Event.destroy_all
   10.times do 
     Event.create(title: Faker::Lorem.sentence(word_count: 3))
   end
   
   #creating events
   User.all.each do |u|
      u.events.destroy_all
   end
   User.all.each do |u|
     event = Event.all.sample
     u.events << event
     u.save
   end
end

