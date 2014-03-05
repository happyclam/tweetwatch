require 'spec_helper'

describe "TrackPages" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  describe "track creation" do
    before { visit root_path }

    describe "with invalid information" do
      it "should not create a track" do
        expect { click_button "Post" }.not_to change(Track, :count)
      end
      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in 'track_tag', with: "#都知事選" }
      it "should create a track" do
        expect { click_button "Post" }.to change(Track, :count).by(1)
      end
    end
  end
  describe "track destruction" do
    before { FactoryGirl.create(:track, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a track" do
        expect { click_link "delete" }.to change(Track, :count).by(-1)
      end
    end
  end
  
end
