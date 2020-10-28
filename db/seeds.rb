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
end

