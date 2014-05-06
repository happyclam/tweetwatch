require 'eventmachine'
require 'optparse'

params = ARGV.getopts('p:')

class Serv < EM::Connection
  attr_accessor :track
  def post_init
    puts "myserv: init"
  end

  def receive_data(data)
    puts "myserv: receive"
    track = data.chomp
    puts track
    send_data "O.K."
    EM.stop if data =~ /stop/i
  end

  def connection_completed
    puts "myserv: completed"
  end

  def unbind
    puts "myserv: unbind"
  end
end

EM.run do
  track = ""
  EM.start_server("127.0.0.1", params["p"].to_i, Serv) do |conn|
    track = conn.track
  end
  $stdout.print "track=" + track
end
