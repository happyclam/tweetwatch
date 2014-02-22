require 'spec_helper'

describe "StaticPages" do
  describe "Home page" do
    before { visit root_path }
    it "should have the content 'Tweet Watch'" do
      expect(page).to have_content('Tweet Watch')
    end
    it "should have the base title" do
      expect(page).to have_title("Tweet Watch App")
    end
    it "should not have a custom page title" do
      expect(page).not_to have_title('| Home')
    end
  end
  describe "Contact page" do
    before { visit contact_path }
    it "should have the content 'Contact'" do
      expect(page).to have_content('Contact')
    end
    it "should have the title 'Contact'" do
      expect(page).to have_title("Tweet Watch App | Contact")
    end
  end
end
