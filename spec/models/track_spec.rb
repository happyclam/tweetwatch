# == Schema Information
#
# Table name: tracks
#
#  id         :integer          not null, primary key
#  tag        :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Track do

  let(:user) { FactoryGirl.create(:user) }
  before do
    @track = user.tracks.build(tag: "#都知事選")
  end

  subject { @track }

  it { should respond_to(:tag) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }

  it {should be_valid}
  describe "when user_id is not present" do
    before { @track.user_id = nil }
    it { should_not be_valid }
  end
  describe "with blank tag" do
    before { @track.tag = " " }
    it { should_not be_valid }
  end

  describe "with tag that is too long" do
    before { @track.tag = "a" * 140 }
    it { should_not be_valid }
  end
end
