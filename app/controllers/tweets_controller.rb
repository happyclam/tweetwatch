# -*- coding:utf-8 -*-
require "pp"
class TweetsController < ApplicationController
  def store
    session[:current_track] = params["track_id"]
    user_id = params["user"]
    # localhost = Net::Telnet::new("Host" => "localhost",
    #                          "Port" => 10000,
    #                          "Timeout" => 5,
    #                          "Telnetmode" => false,
    #                          "Output_log" => "./temp0.log",
    #                          "Prompt" => nil)
    # localhost.cmd("stop") { |c| print c }
    # localhost.close
    # localhost = nil

    return redirect_to (user_id) ? user_path(user_id) : root_path

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
