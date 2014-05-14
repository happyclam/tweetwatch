# == Schema Information
#
# Table name: servs
#
#  id         :integer          not null, primary key
#  track      :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Serv do
#  pending "add some examples to (or delete) #{__FILE__}"
  let(:user) {FactoryGirl.create(:user)}
  before do
#    @serv = Serv.new(track: "#NHK", user_id: user.id)
    @serv = user.build_serv(track: "#NHK")
  end
  subject {@serv}
  it{should respond_to(:track)}
  it{should respond_to(:user_id)}
  it{should respond_to(:user)}
  its(:user) {should eq user}

  it{should be_valid}
  describe "when user_id is not present" do
    before {@serv.user_id = nil}
    it {should_not be_valid}
  end

  describe ":down" do
    it "should be an initial status" do
      @serv.should be_down
    end

    it "should change to :prepared on :start" do
      @serv.start!
      @serv.should be_prepared
    end

    it "should change to :prepared on :start" do
      @serv.start!
      lambda {@serv.send(start)}.should raise_error
    end

    it "should change to :storing on :store" do
      @serv.start!
      @serv.store!
      @serv.should be_storing
    end

    it "should change to :storing on :store" do
      @serv.start!
      @serv.store!
      lambda {@serv.send(start)}.should raise_error
      lambda {@serv.send(store)}.should raise_error
      # ["start", "store"].each do |action|
      #   lambda {@serv.send(action)}.should raise_error
      # end
      @serv.stop!
      @serv.should be_down

    end

    # ["start!", "store!"].each do |action|
    #   it "should raise an error for #{action}" do
    #     lambda {@serv.send(action)}.should raise_error
    #   end
    # end
   
  end
end
