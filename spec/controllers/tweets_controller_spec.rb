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
  describe "ログインしてようがしてなかろうがcheckは通る" do
    it {
      get 'check', format: :js
      expect(response).to be_success
    }
  end
  describe "未ログイン" do
    it "GET stop" do
      get 'stop', format: :js
      expect(response).to redirect_to(signin_path)
    end
    it "GET track" do
      get 'track', track: "#tvosaka"
      expect(response).to redirect_to(signin_path)
    end
  end
  describe "ログイン後" do
    include_examples "login as user"
    it "GET stop" do
      get 'stop', format: :js, user: user.id
      expect(response).to redirect_to(root_url)
    end
    it "GET track" do
      get 'track', track: "#tvosaka", user: user
      expect(response).to redirect_to(root_url)
    end
  end
  describe "adminでログイン後stop" do
    include_examples "login as admin"
    it "GET stop" do
      get 'stop', format: :js, user: admin.id
      expect(response).to redirect_to(user_path(admin))
    end
  end
  describe "adminでログイン後track" do
    include_examples "login as admin"
    before{
      controller.stub(:current_user).and_return(admin)
      controller.stub_chain("current_user.serv.status").and_return(admin.serv.status)
    }
    it "GET track" do
      get 'track', track: "#tvosaka", user: admin
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
