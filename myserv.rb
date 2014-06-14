require 'eventmachine'
require 'optparse'
require 'sqlite3'
require 'json'
require 'uri'
require 'pp'

require 'twitter/json_stream'

params = ARGV.getopts('p:t:c:k:s:a:d:')

class Serv < EM::Connection
  attr_accessor :uid
  attr_accessor :dbname
  attr_accessor :track
  attr_accessor :c_key
  attr_accessor :c_secret
  attr_accessor :a_key
  attr_accessor :a_secret
  def post_init
    puts "myserv: init"
  end

  def receive_data(data)
    puts "myserv: receive"
    puts data
    
    case data
    when /stop/i
      send_data "O.K."
      EM.stop
    when /check/i
      send_data @track
      puts "sended="+@track
    when /store/i
      send_data @track
      tracking(@track, @c_key, @c_secret, @a_key, @a_secret, @uid, @dbname)
    else
      send_data "O.K."
    end

  end

  def connection_completed
    puts "myserv: completed"
  end

  def unbind
    puts "myserv: unbind"
  end

  def tracking(track, c_key, c_secret, a_key, a_secret, uid, dbname)
    stream = Twitter::JSONStream.connect(
                                         :path    => "/1.1/statuses/filter.json?track=" + URI.encode(track),
                                         :oauth => {
                                           :consumer_key    => c_key,
                                           :consumer_secret => c_secret,
                                           :access_key      => a_key,
                                           :access_secret   => a_secret
                                         },
                                         :ssl => true
                                         )
    stream.each_item do |item|
      db = SQLite3::Database.new( dbname )

      tw_json = JSON.parse(item)
#      tw_json = JSON.parse(item, {:symbolize_names => true})
#pp tw_json
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
      sql = "INSERT INTO tweets (own_user_id, user_id, user_name, user_screen_name, user_text, post_hashtags, user_image, user_description, status_id, reply_status_id, reply_user_id, reply_user_screen_name, updated_at, created_at) VALUES (#{uid}, '#{user_id}', '#{user_name}', '#{user_screen_name}', '#{user_text}', '#{post_hashtags}', '#{user_image}', '#{user_description}', '#{status_id}', '#{reply_status_id}', '#{reply_user_id}', '#{reply_user_screen_name}', '#{Time.now}', '#{Time.now}')"

      $stdout.print "sql= #{sql}\n"
      $stdout.flush
      db.execute(sql)
      db.close
    end

    stream.on_error do |message|
      $stdout.print "error: #{message}\n"
      $stdout.flush
    end

    stream.on_reconnect do |timeout, retries|
      $stdout.print "reconnecting in: #{timeout} seconds\n"
      $stdout.flush
    end

    stream.on_max_reconnects do |timeout, retries|
      $stdout.print "Failed after #{retries} failed reconnects\n"
      $stdout.flush
    end

    trap('TERM') {  
      $stdout.print "trap\n"
      $stdout.flush
      stream.stop
    }
  end
  
end
#------------------------------------------------------------
EM.run do
  $stdout.print "first" + "\n"
  EM.start_server("127.0.0.1", 10000 + params["p"].to_i, Serv) do |conn|
    conn.track = params["t"]
    conn.uid = params["p"].to_i
    conn.dbname = params["d"].to_s
    conn.c_key = params["c"]
    conn.c_secret = params["k"]
    conn.a_key = params["s"]
    conn.a_secret = params["a"]
    $stdout.print conn.track + "\n"
  end
  $stdout.print "end" + "\n"
end
