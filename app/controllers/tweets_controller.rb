# -*- coding:utf-8 -*-
require "net/telnet"
class TweetsController < ApplicationController
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
#      current_user.serv.store if current_user.serv.status == PREPARED      
    rescue
      #検索タグがDB内と食い違っているか、またはサーバースクリプトが起動していない
      @status_check = false
      current_user.serv.track = nil
#      return redirect_to user_path(user_id)
    end
p "status_check="+@status_check.to_s
    render

  end

  def start
p "tweets.start"
    user_id = params["user"]
    track = current_user.serv.track
    unless track
      flash[:alert] = "右側のリストから、タグを指定してください"
      render :js => "window.location.href='"+user_path(user_id)+"'"
      return
    end
    begin
      ret = system("ruby myserv.rb -p#{10000 + user_id.to_i} -t#{track} &")
      current_user.serv.start if ret
    rescue
      current_user.serv.down
      render :js => "window.location.href='"+user_path(user_id)+"'"
      return

    end
    render

  end

  def store
p "tweets.store"
    user_id = current_user.id
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + user_id.to_i,
                                   "Timeout" => 1,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => current_user.serv.track)
      localhost.cmd("store") { |c| print c }
      localhost.close
      localhost = nil
      @status_store = true
      current_user.serv.store if current_user.serv.status == PREPARED      
    rescue
      @status_store = false
#      current_user.serv.track = nil
    end
    return redirect_to user_path(user_id)

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
      current_user.serv.stop if current_user.serv
    rescue
      @status_stop = false
      flash[:alert] = $!.to_s
      p $!
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
