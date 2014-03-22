# -*- coding:utf-8 -*-
require 'rubygems'
require 'bundler'
require 'sqlite3'
require 'json'
require 'uri'
require 'pp'

Bundler.require

require 'twitter/json_stream'

# TwitterのAPIキー情報を環境変数から取得
TWITTER_CONSUMER_KEY        ||= ENV['TWITTER_CONSUMER_KEY']
TWITTER_CONSUMER_SECRET     ||= ENV['TWITTER_CONSUMER_SECRET']
TWITTER_OAUTH_TOKEN         ||= ENV['TWITTER_OAUTH_TOKEN']
TWITTER_OAUTH_TOKEN_SECRET  ||= ENV['TWITTER_OAUTH_TOKEN_SECRET']
TRACKING                    ||= ENV['TRACKING']

# # DBへの接続情報を環境変数から取得
# DB_HOSTNAME   ||= ENV['DB_HOSTNAME']
# DB_USER_NAME  ||= ENV['DB_USER_NAME']
# DB_PASSWORD   ||= ENV['DB_PASSWORD']
# DB_NAME       ||= ENV['DB_NAME']
DBNAME = "./db/development.sqlite3"

EventMachine::run {
  stream = Twitter::JSONStream.connect(
#    :path    => "/1.1/statuses/filter.json?follow=" + URI.encode(FOLLOWS),
    :path    => "/1.1/statuses/filter.json?track=" + URI.encode(TRACKING),
    :oauth => {
      :consumer_key    => TWITTER_CONSUMER_KEY,
      :consumer_secret => TWITTER_CONSUMER_SECRET,
      :access_key      => TWITTER_OAUTH_TOKEN,
      :access_secret   => TWITTER_OAUTH_TOKEN_SECRET
    },
    :ssl => true
  )
  stream.each_item do |item|
    db = SQLite3::Database.new( DBNAME )
#    $stdout.print "item: #{item}\n"
#    $stdout.flush

    tw_json = JSON.parse(item)
#    tw_json = JSON.parse(item, {:symbolize_names => true})

    user_id                         = tw_json['user']['id_str']
    user_name                       = tw_json['user']['name'].gsub(/\\/, '\&\&').gsub(/'/, "''")
    user_screen_name                = tw_json['user']['screen_name'].gsub(/\\/, '\&\&').gsub(/'/, "''")
    user_text                       = tw_json['text'].gsub(/\\/, '\&\&').gsub(/'/, "''") if tw_json['text']
    post_hashtags                   = tw_json['entities']['hashtags'].join(',') rescue nil
    user_image                      = tw_json['user']['profile_image_url']
    user_description                = tw_json['user']['description'].gsub(/\\/, '\&\&').gsub(/'/, "''") if tw_json['user']['description']
    status_id               = tw_json['id_str']
    reply_status_id         = tw_json['in_reply_to_status_id_str'] rescue nil
    reply_user_id           = tw_json['in_reply_to_user_id_str'] rescue nil
    reply_user_screen_name  = tw_json['in_reply_to_screen_name'] rescue nil

    # tweetsテーブルに書き込み
    sql = "INSERT INTO tweets (user_id, user_name, user_screen_name, user_text, post_hashtags, user_image, user_description, status_id, reply_status_id, reply_user_id, reply_user_screen_name, updated_at, created_at) VALUES ('#{user_id}', '#{user_name}', '#{user_screen_name}', '#{user_text}', '#{post_hashtags}', '#{user_image}', '#{user_description}', '#{status_id}', '#{reply_status_id}', '#{reply_user_id}', '#{reply_user_screen_name}', '#{Time.now}', '#{Time.now}')"

    $stdout.print "sql= #{sql}\n"
    $stdout.flush
    db.execute(sql)
    db.close
  end

  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end

  # 再接続は書いていないです。書いて教えてくださいw
  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end

  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end

  trap('TERM') {  
    $stdout.pring "trap\n"
    $stdout.flush
    stream.stop
    EventMachine.stop if EventMachine.reactor_running? 
  }
}
