require 'eventmachine'
require 'optparse'
require 'sqlite3'
require 'json'
require 'uri'
require 'pp'

require 'twitter/json_stream'

TWITTER_CONSUMER_KEY = 'p6jdrM03fqw2rgN9k8Erg'
TWITTER_CONSUMER_SECRET = 'xP4SdHABYQg83E7947xy8aBLUPgc820Bt03B9SPZug'
TWITTER_OAUTH_TOKEN = '72840202-USLn9jVAr3p4VqIWRk3MJlbHALaTmZHlDodSKIs5I'
TWITTER_OAUTH_TOKEN_SECRET = 'RbTNGwxgfQW5HjEookk4kG1pMZZtq4VcSiPnFlghIkCLx'
# # TwitterのAPIキー情報を環境変数から取得
# TWITTER_CONSUMER_KEY        ||= ENV['TWITTER_CONSUMER_KEY']
# TWITTER_CONSUMER_SECRET     ||= ENV['TWITTER_CONSUMER_SECRET']
# TWITTER_OAUTH_TOKEN         ||= ENV['TWITTER_OAUTH_TOKEN']
# TWITTER_OAUTH_TOKEN_SECRET  ||= ENV['TWITTER_OAUTH_TOKEN_SECRET']
# #TRACKING                    ||= ENV['TRACKING']

DBNAME = "./db/development.sqlite3"

params = ARGV.getopts('p:t:')

class Serv < EM::Connection
  attr_accessor :track
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
    # when /syn/i
    #   send_data "ack"
    when /check/i
      send_data @track
    # when /store/i
    #   send_data @track
    #   tracking(@track)
    else
      send_data "O.K."
      tracking(@track)
    end

    # EM.stop if data =~ /stop/i
    # if data =~ /syn/i
    #   send_data "ack"
    # else
    #   if data =~ /check/i
    #     send_data @track
    #   else
    #     send_data "O.K."
    #     tracking(@track)
    #   end
    # end
  end

  def connection_completed
    puts "myserv: completed"
  end

  def unbind
    puts "myserv: unbind"
  end

  def tracking(track)
    stream = Twitter::JSONStream.connect(
                                         :path    => "/1.1/statuses/filter.json?track=" + URI.encode(track),
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
  EM.start_server("127.0.0.1", params["p"].to_i, Serv) do |conn|
    conn.track = params["t"]
    $stdout.print conn.track + "\n"
  end
  $stdout.print "end" + "\n"
end
