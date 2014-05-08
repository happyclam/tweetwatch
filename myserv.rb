require 'eventmachine'
require 'optparse'

params = ARGV.getopts('p:t:')

class Serv < EM::Connection
  attr_accessor :track
  def post_init
    puts "myserv: init"
  end

  def receive_data(data)
    puts "myserv: receive"
    puts data
    if data =~ /syn/i
      send_data "ack"
    else
      @track = data.chomp
      send_data "O.K."
    end
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
  $stdout.print "first" + "\n"
  EM.start_server("127.0.0.1", params["p"].to_i, Serv) do |conn|
    conn.track = params["t"]
    $stdout.print conn.track + "\n"
  end
  $stdout.print "end" + "\n"
end
