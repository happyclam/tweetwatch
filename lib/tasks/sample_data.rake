namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Example User",
                         email: "example@railstutorial.jp",
                         password: "foobar",
                         password_confirmation: "foobar",
                         admin: true)
    aiueo = User.create!(name: "aiueo",
                         email: "aiueo@gmail.com",
                         password: "aiueoa",
                         password_confirmation: "aiueoa",
                         admin: false)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.jp"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end
