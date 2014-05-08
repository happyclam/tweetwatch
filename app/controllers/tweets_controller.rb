# -*- coding:utf-8 -*-
require "net/telnet"
class TweetsController < ApplicationController
  def check
    user_id = params["user"]

    @status_check = nil
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + current_user.id,
                                   "Timeout" => 3,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => "ack")
      localhost.cmd("syn") { |c| print c }
      localhost.close
      localhost = nil
      @status_check = true
    rescue
      @status_check = false
      p $!
    end
    render

  end

  def start
    user_id = params["user"]
    track = session["current_track"]
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
    end
    render
#    return redirect_to (user_id) ? user_path(user_id) : root_path
    
  end

  def stop
    user_id = params["user"]

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
    end
    render
#    return redirect_to (user_id) ? user_path(user_id) : root_path
  end

  def store
    session[:current_track] = params["track"]
    return redirect_to user_path(params["user"])

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
