# -*- coding:utf-8 -*-
require "net/telnet"
class TweetsController < ApplicationController
#   def check
# p "tweets.check"
#     user_id = params["user"]

#     @status_check = nil
#     begin
#       localhost = Net::Telnet::new("Host" => "localhost",
#                                    "Port" => 10000 + current_user.id,
#                                    "Timeout" => 1,
#                                    "Telnetmode" => false,
#                                    "Output_log" => "./output.log",
#                                    "Dump_log" => "./dump.log",
#                                    "Prompt" => "ack")
#       localhost.cmd("syn") { |c| print c }
#       localhost.close
#       localhost = nil
#       @status_check = true
#     rescue
#       @status_check = false
#       session["current_track"] = nil
#       p $!
#     end
#     render

#   end

  def check
p "tweets.check"
p "current_user="+current_user.inspect
    user_id = current_user.id
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + user_id.to_i,
                                   "Timeout" => 1,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => current_user.serv.track)
      localhost.cmd("check") { |c| print c }
      localhost.close
      localhost = nil
      @status_check = true
    rescue
      #検索タグがDB内と食い違っているか、またはサーバースクリプトが起動していない
      @status_check = false
      current_user.serv.track = nil
      return redirect_to user_path(user_id)
    end
    render

  end

  def start
p "tweets.start"
    user_id = params["user"]
    track = current_user.serv.track
    unless track
      #      return redirect_back_or user_path(user_id)
      flash[:alert] = "右側のリストから、タグを指定してください"
      render :js => "window.location.href='"+user_path(user_id)+"'"
      return
    end
    begin
      @status_start = system("ruby myserv.rb -p#{10000 + user_id.to_i} -t#{track} &")
    rescue
      @status_start = false
#      current_user.serv.track = nil
      return redirect_to user_path(user_id)
    end
    render
    
  end

  def stop
p "tweets.stop"
    user_id = params["user"]

    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + user_id.to_i,
                                   "Timeout" => 1,
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
#      current_user.serv.track = nil
      return redirect_to user_path(user_id)
    end
    render

  end

  def track
p "tweets.track"
#    user = User.find(params["user"])
#    user.serv.track = params["track"]
    current_user.serv.update_attribute(:track, params["track"])
    return redirect_to user_path(params["user"])

  end

  def graph
#    render :text => "params=#{params.to_s}"
    @id = params["user"]
    condition = "%" + params["track"].sub("#", "") + "%" 
    ret = Tweet.where('post_hashtags like ?', condition).group(:user_text).order('count_user_text desc').count('user_text')

    @categories = []
    @data = []
    
    ret.each{|key, val|
      @categories << key[0..TAG_MAX_LENGTH]
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
