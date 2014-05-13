# -*- coding:utf-8 -*-
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    samp  = User.create!(name: "Example User",
                         email: "example@railstutorial.jp",
                         password: "foobar",
                         password_confirmation: "foobar",
                         admin: false)
    samp.build_serv(track: "#NHK")
    samp.serv.save
    aiueo = User.create!(name: "aiueo",
                         email: "aiueo@gmail.com",
                         password: "aiueoa",
                         password_confirmation: "aiueoa",
                         admin: true)
    aiueo.build_serv(track: "#fujitv")
    aiueo.serv.save
    contents = []
    contents << "宇都宮"    
    contents << "細川"    
    8.times do
      contents << Faker::Lorem.characters(20)
    end

    tags = []
    tags << "#都知事選"    
    tags << "#NHK"    
    tags << "#fujitv"    
    7.times do
      tags << "#" + Faker::Name.title
    end

    tracks = []                         
    tracks << {:text=>"都知事選", :indices=>[125, 130]}
    tracks << {:text=>"NHK", :indices=>[100, 110]}
    tracks << {:text=>"fujitv", :indices=>[100, 110]}
    7.times do
      tracks << {:text=>(Faker::Lorem.characters(10)), :indices=>[125, 130]}
    end
    200.times.each_with_index do |idx|
        n = rand(10)
        #都知事選タグがついているものは、本文（content）に細川か宇都宮しか入らないようにする
        if n == 0
          tag = tags[n].clone
          content = contents[rand(2)].clone
          track = tracks[rand(2)].clone
        else
          tag = tags[n].clone
          content = contents[rand(10)].clone
          track = tracks[rand(10)].clone
        end
        tweet = Tweet.create(user_id: idx + 1,
                         user_name: "ユーザ" + (idx + 1).to_s,
                         user_screen_name: "user" + (idx + 1).to_s,
                         user_description: Faker::Lorem.sentence(5),
                         user_text: content + " " + tag,
                         post_hashtags: track.to_json,
                         status_id: idx + 1,
                         reply_status_id: 0,
                         reply_user_id: 0,
                         reply_user_screen_name: ""
                         )
    end


    30.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.jp"
      password  = "password"
      user = User.create!(name: name,
                          email: email,
                          password: password,
                          password_confirmation: password)
      user.build_serv(track: "#" + (n * 99).to_s)
      user.serv.save
    end
    
    users = User.all(limit: 10)
    users.each_with_index{|user, idx| user.tracks.create!(tag: tags[idx])}
  end

  task products: :environment do
    aiueo = User.create!(name: "aiueo",
                         email: "aiueo@gmail.com",
                         password: "aiueoa",
                         password_confirmation: "aiueoa",
                         admin: true)
    aiueo.build_serv(track: "#NHK")
    aiueo.serv.save
  end
end
