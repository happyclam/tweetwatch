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
  end
  describe "ログイン後" do
    include_examples "login as user"
    it "GET stop" do
      get 'stop', format: :js, id: user.id
      expect(response).to redirect_to(root_url)
    end
    it "GET track" do
      get 'track', track: "#tvosaka", id: user
      expect(response).to redirect_to(root_url)
    end
  end
  describe "adminでログイン後" do
    include_examples "login as admin"
    before{
      controller.stub(:current_user).and_return(admin)
      controller.stub_chain("current_user.serv.stop").and_return(admin.serv.stop)
      controller.stub_chain("current_user.serv.status").and_return(admin.serv.status)
    }
    it "GET stop" do
      get 'stop', format: :js, id: admin.id
      expect(response).to redirect_to(user_path(admin))
    end
    it "GET track" do
      get 'track', track: "#tvosaka", id: admin
      expect(response).to redirect_to(user_path(admin))
    end
  end
  # describe "for non-signed-in users" do
  #   let(:user) {FactoryGirl.create(:user)}
  #   describe "in the Tweets controller" do
  #     describe "submitting to the check action" do
  #       before {get 'check', format: :js}
  #       specify {expect(response).to redirect_to(signin_path)}
  #     end
  #   end
  # end
end
