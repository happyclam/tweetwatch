# -*- coding:utf-8 -*-
require "net/telnet"
class TweetsController < ApplicationController
  def start
    user_id = params["user"]
    @status_stop = nil
    begin
      @status_start = system("ruby myserv.rb -p #{10000 + user_id.to_i} &")
    rescue
      @status_start = false
      p $!
    end
    render
#    return redirect_to (user_id) ? user_path(user_id) : root_path
    
  end

  def stop
    user_id = params["user"]

    @status_start = nil
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + user_id.to_i,
                                   "Timeout" => 3,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => "O.K.")
      localhost.cmd("stop") { |c| print c }
      localhost.close
      localhost = nil
      @status_stop = true
    rescue
      @status_stop = false
      p $!
    end
    render
#    return redirect_to (user_id) ? user_path(user_id) : root_path
  end

  def store
    user_id = params["user"]
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + user_id.to_i,
                                   "Timeout" => 3,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => "O.K.")
      localhost.cmd(params["track"]) { |c| print c }
      localhost.close
      localhost = nil
      @current_track = params["track_id"]
    rescue
      @current_track = $!

    end
    render
#    return redirect_to (user_id) ? user_path(user_id) : root_path

  end

  def track
#    render :text => "params=#{params.to_s}"
    @id = params["user"]
    @test = params["track"]
    condition = "%" + params["track"].sub("#", "") + "%" 
    ret = Tweet.where('post_hashtags like ?', condition).group(:user_text).order('count_user_text desc').count('user_text')

    @categories = []
    @data = []
    
    ret.each{|key, val|
      @categories << key[0..40]
      @data << val
    }

    @track = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "bar")
      f.title(:text => params["track"])
      f.xAxis(:categories => @categories)
      f.series(:name => "ツイート数",
               :data => @data)
    end

#    render :text => "ret=#{ret.to_s}"
  end

end
