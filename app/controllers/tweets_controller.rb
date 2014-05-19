# -*- coding:utf-8 -*-
require "net/telnet"
class TweetsController < ApplicationController
  def check
p "tweets.check"
p "current_user="+current_user.inspect
p "check:track="+current_user.serv.track.to_s
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
    c = current_user.c_key
    k = current_user.c_secret
    s = current_user.a_key
    a = current_user.a_secret
    unless track
      flash[:alert] = "右側のリストから、タグを指定してください"
      render :js => "window.location.href='"+user_path(user_id)+"'"
      return
    end
    begin
p "ruby myserv.rb -p#{user_id.to_i} -t#{track} -c#{c} -k#{k} -s#{s} -a#{a} &"
      ret = system("ruby myserv.rb -p#{user_id.to_i} -t#{track} -c#{c} -k#{k} -s#{s} -a#{a} &")

      current_user.serv.start if ret
      ret = system("sleep 5")
    rescue
      current_user.serv.down
      render :js => "window.location.href='"+user_path(user_id)+"'"
      return

    end
    render

  end

  def store
p "tweets.store"
p "user_id="+current_user.id.to_s
p "store:track="+current_user.serv.track
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + current_user.id,
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
      current_user.serv.stop
      flash[:alert] = $!.to_s
      p $!
      return redirect_to user_path(current_user), notice: $!.to_s
    end
p "status_store="+@status_store.to_s
p "server_status="+current_user.serv.status.to_s
    redirect_to user_path(current_user.id)

  end

  def stop
p "tweets.stop"
p "status="+current_user.serv.status.to_s
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
      flash[:alert] = $!.to_s
      p $!
    end
    current_user.serv.stop if current_user.serv
p "status="+current_user.serv.status.to_s
    render

  end

  def track
p "tweets.track"
#    user = User.find(params["user"])
#    user.serv.track = params["track"]
    case current_user.serv.status
    when DOWN
      current_user.serv.update_attribute(:track, params["track"])
    when PREPARED, STORING
      flash[:alert] = "サーバーを停止してから選択してください"
    else
      flash[:alert] = "Error"
    end
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
