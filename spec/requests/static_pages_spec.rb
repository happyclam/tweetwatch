require 'spec_helper'

describe "StaticPages" do
  describe "Home page" do
    it "should have the content 'TweetWatch'" do
      visit '/static_pages/home'
      expect(page).to have_content('TweetWatch')
    end

    it "should not have a custom page title" do
      visit '/static_pages/home'
      expect(page).not_to have_title('| Home')
    end
  end
 end
