# -*- coding:utf-8 -*-
class TweetsController < ApplicationController
  def track
#    render :text => "params=#{params.to_s}"
    condition = "%" + params["track"].sub("#", "") + "%" 
    ret = Tweet.where('post_hashtags like ?', condition).group(:user_text).order('count_user_text desc').count('user_text')
    render :text => "ret=#{ret.to_s}"
  end

end
