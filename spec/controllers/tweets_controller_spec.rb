require 'spec_helper'

describe TweetsController do
  shared_examples "login as user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user, no_capybara: true }
  end
  shared_examples "login as admin" do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin, no_capybara: true }
  end
  describe "ログインしてようがしてなかろうが許可されるmethod" do
    let(:user) { FactoryGirl.create(:user) }
    it "GET check" do
      get 'check', format: :js, id: user
      expect(response).to be_success
    end 
    it "GET graph" do
      get 'graph', track: "#NHK", id: user
      expect(response).to be_success
    end
  end
  describe "未ログイン" do
    let(:user) { FactoryGirl.create(:user) }
    it "GET stop" do
      get 'stop', format: :js, id: user
      expect(response).to redirect_to(signin_path)
    end
    it "GET track" do
      get 'track', track: "#tvosaka", id: user
      expect(response).to redirect_to(signin_path)
    end
    it "GET start" do
      get 'start', id: user
      expect(response).to redirect_to(signin_path)
    end
    it "GET store" do
      get 'store', id: user
      expect(response).to redirect_to(signin_path)
    end
  end
  describe "admin以外でログイン後" do
    include_examples "login as user"
    it "GET stop" do
      get 'stop', format: :js, id: user.id
      expect(response).to redirect_to(root_url)
    end
    it "GET track" do
      get 'track', track: "#tvosaka", id: user
      expect(response).to redirect_to(root_url)
    end
    it "GET start" do
      get 'start', id: user
      expect(response).to redirect_to(root_url)
    end
    it "GET store" do
      get 'store', id: user
      expect(response).to redirect_to(root_url)
    end
  end
  describe "adminでログイン後" do
    include_examples "login as admin"
    before{
      controller.stub(:current_user).and_return(admin)
      controller.stub_chain("current_user.serv.stop").and_return(admin.serv.stop)
      controller.stub_chain("current_user.serv.status").and_return(admin.serv.status)
      controller.stub_chain("current_user.serv.track").and_return(admin.serv.track)
      controller.stub_chain("current_user.serv.store").and_return(admin.serv.store)
    }
    it "GET stop" do
      get 'stop', format: :js, id: admin.id
      expect(response).to be_success
    end
    it "GET stop" do
      get 'stop', id: admin.id
      expect(response).to redirect_to(user_path(admin))
    end
    it "GET track" do
      get 'track', track: "#tvosaka", id: admin
      expect(response).to redirect_to(user_path(admin))
    end
    it "GET start" do
      get 'start', id: admin
      expect(response).to be_success
    end
    it "GET store" do
      get 'store', id: admin
      expect(response).to redirect_to(user_path(admin))
    end
  end
#  def mock_serv(stubs={})
#    @mock_serv ||= mock_model(Serv, stubs)
#  end
  describe "adminでログイン後(仮)" do
    include_examples "login as admin"
#    let(:serv) {double("Serv")}
#    let(:serv) {FactoryGirl.create(:serv, user_id: admin.id)}
#    let(:serv) {admin.build_serv(track: "#tvosaka")}
    before{
      admin.build_serv(track: "#NHK")
      controller.stub(:current_user).and_return(admin)
      controller.stub_chain("current_user.serv").and_return(admin.serv)
      controller.stub_chain("current_user.serv.status").and_return(DOWN)
#      @serv = mock_model(Serv, :user_id => admin.id)
    }
#    Serv.should_receive(:find).with(user_id: admin.id).and_return(serv)
    it "GET track & status==DOWN" do
      get 'track', track: "#tvosaka", id: admin
#      admin.serv.should_receive(:update_attributes).and_return(true)
#      expect(serv).to receive(:update_attributes).with(:track => "#tvosaka"){true}
#      serv.should_receive(:update_attributes).with(:track => "#tvosaka")
#      @serv.should_receive(:update_attributes).with(:track => "#tvosaka")
    end
    before{
      controller.stub(:current_user).and_return(admin)
      controller.stub_chain("current_user.serv.status").and_return(PREPARED)
    }
    it "GET track & status==PREPARED" do
      get 'track', track: "#tvosaka", id: admin
      flash[:alert].should == "サーバーを停止してから選択してください"
    end
  end
end
