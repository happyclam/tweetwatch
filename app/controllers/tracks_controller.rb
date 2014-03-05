class TracksController < ApplicationController
#  before_action :set_track, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user
  before_action :correct_user, only: :destroy

  # POST /tracks
  # POST /tracks.json
  def create
    @track = current_user.tracks.build(track_params)
    if @track.save
      flash[:success] = "Track created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
    # @track = Track.new(track_params)

    # respond_to do |format|
    #   if @track.save
    #     format.html { redirect_to @track, notice: 'Track was successfully created.' }
    #     format.json { render action: 'show', status: :created, location: @track }
    #   else
    #     format.html { render action: 'new' }
    #     format.json { render json: @track.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.json
  def destroy
    @track.destroy
    redirect_to root_url

    # @track.destroy
    # respond_to do |format|
    #   format.html { redirect_to tracks_url }
    #   format.json { head :no_content }
    # end
  end

  private
    def track_params
      params.require(:track).permit(:tag)
    end
    def correct_user
      @track = current_user.tracks.find_by(id: params[:id])
      redirect_to root_url if @track.nil?
    end
end
