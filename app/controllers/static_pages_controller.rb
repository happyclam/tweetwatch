class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @track = current_user.tracks.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def contact
  end

end
