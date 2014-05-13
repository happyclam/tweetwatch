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

end
