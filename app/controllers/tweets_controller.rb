# -*- coding:utf-8 -*-
require "net/telnet"
class TweetsController < ApplicationController
  before_action :signed_in_user, except: [:graph, :check]
  before_action :correct_user, only: [:track, :start, :stop, :store]

  def check
p "tweets.check"
    unless current_user
      @status_check = false
      render
      return
    end
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + current_user.id.to_i,
                                   "Timeout" => 1,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => current_user.serv.track)
      localhost.cmd("check") { |c| print c }
      localhost.close
      localhost = nil
      @status_check = true
    rescue Net::ReadTimeout
p "check.readtimeout"
      localhost = nil
      @status_check = true
    rescue
p "check.exception"
      p $!
      #検索タグがDB内と食い違っているか、またはサーバースクリプトが起動していない
      @status_check = false
#      current_user.serv.track = nil
    end
p "status_check="+@status_check.to_s
    render

    # if @status_check
    #   @status_str = "検索タグ:" + current_user.serv.track + " - status:集計中"
    # else
    #   @status_str = "検索タグ:" + current_user.serv.track + " - status:停止中"
    # end
# jq_str = <<"JQ_STR"
#   $('#server_status').html("#{@status_str}");
#   $('#server_start').hide(500);
#   $('#server_stop').show(500);
# JQ_STR

#    render :text => "alert('hello')"
#    render :file => "tweets/check.js.erb"
#    render :inline => jq_str
#    render :text => jq_str

  end

  def start
p "tweets.start"
    track = current_user.serv.track
    d = (ENV["RAILS_ENV"] == "production") ? "./db/production.sqlite3" : "./db/development.sqlite3"
    c = current_user.c_key
    k = current_user.c_secret
    s = current_user.a_key
    a = current_user.a_secret
    unless track
      flash[:alert] = "右側のリストから、タグを指定してください。"
      render :js => "window.location.href='"+user_path(current_user)+"'"
      return
    end
    unless (c.present? && k.present? && s.present? && a.present?)
      flash[:alert] = "TwitterAPIを利用するための設定が完了していません。settingメニューから設定してください。"
      render :js => "window.location.href='"+user_path(current_user)+"'"
      return
    end      

    begin
p "ruby myserv.rb -p#{current_user.id.to_i} -t#{track} -c#{c} -k#{k} -s#{s} -a#{a} -d#{d} &"
      ret = system("ruby myserv.rb -p#{current_user.id.to_i} -t#{track} -c#{c} -k#{k} -s#{s} -a#{a} -d#{d} &")

      current_user.serv.start if ret
      ret = system("sleep 5")
    rescue
p "start.exception"
      p $!
      current_user.serv.down
      render :js => "window.location.href='"+user_path(current_user)+"'"
      return

    end
    render

  end

  def store
p "tweets.store"
p "store:track="+current_user.serv.track.to_s
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
    rescue Net::ReadTimeout
p "store.readtimeout"
      localhost = nil
    rescue
p "store.exception"
      @status_store = false
#      current_user.serv.stop
      p $!
      current_user.serv.stop
      flash[:alert] = $!.to_s
      return redirect_to user_path(current_user), notice: $!.to_s
    end
p "status_store="+@status_store.to_s
p "server_status="+current_user.serv.status.to_s
    redirect_to user_path(current_user)

  end

  def stop
p "tweets.stop"
#p "status="+current_user.serv.status.to_s
    begin
      localhost = Net::Telnet::new("Host" => "localhost",
                                   "Port" => 10000 + current_user.id.to_i,
                                   "Timeout" => 1,
                                   "Telnetmode" => false,
                                   "Output_log" => "./output.log",
                                   "Dump_log" => "./dump.log",
                                   "Prompt" => "O.K.")
      localhost.cmd("stop") { |c| print c }
      localhost.close
      localhost = nil
      flash[:alert] = nil
      @status_stop = true
    rescue
      @status_stop = false
      flash[:alert] = $!.to_s
      p $!
    end
    current_user.serv.stop if current_user.serv
#p "status="+current_user.serv.status.to_s
#    render :js => "window.location.href='"+user_path(current_user)+"'"
#    respond_with current_user, :location => user_path(current_user)
    respond_to do |format|
      format.html {redirect_to user_path(current_user)}
      format.js {render :js => "window.location.href='"+user_path(current_user)+"'"}
    end
#    return
#    render

  end

  def track
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
    return redirect_to user_path(params["id"])

  end

  def graph
#    render :text => "params=#{params.to_s}"
#p params
    @track = params["track"]
    @user = User.find(params["id"])
    condition = "%" + @track.sub("#", "") + "%" 
    ret = @user.tweets.where('post_hashtags like ?', condition).group(:user_text).order('count_user_text desc').count('user_text')

    @categories = []
    @data = []
    
    ret.each{|key, val|
      @categories << key[0..TAG_MAX_LENGTH]
      @data << val
    }

    @graph = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "bar")
      f.title(:text => params["track"])
      f.xAxis(:categories => @categories)
      f.series(:name => "ツイート数",
               :data => @data)
    end

#    render :text => "ret=#{ret.to_s}"
  end

  private
    def correct_user
p "tweets.correct_user"
#      redirect_to root_url if current_user.serv.nil?
#      redirect_to user_path(current_user) unless current_user.admin
      redirect_to root_url unless current_user.admin
    end

end
