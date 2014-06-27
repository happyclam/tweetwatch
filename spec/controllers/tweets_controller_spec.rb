require 'spec_helper'

describe TweetsController do
  shared_examples "login as user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user, no_capybara: true }
  end
  shared_examples "login as admin" do
    let(:admin) { FactoryGirl.create(:user) }
    before { sign_in admin, no_capybara: true }
  end
  describe "ログインしてようがしてなかろうがcheckは通る" do
    it {
      get 'check', format: :js
      expect(response).to be_success
    }
  end
  describe "未ログインでstop" do
    it {
      get 'stop', format: :js
      expect(response).to redirect_to(signin_path)
    }
  end
  # describe "ログイン後stop" do
  #   include_examples "login as user"
  #   it {
  #     get 'stop', format: :js, user: user.id
  #     expect(response).to redirect_to(user_path(user))
  #   }
  # end
  # describe "adminでログイン後stop" do
  #   include_examples "login as admin"
  #   it {
  #     get 'stop'
  #     expect(response).to redirect_to(user_path(admin))
  #   }
  # end

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
