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

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:track, user: user, tag: "#都知事選")
        FactoryGirl.create(:track, user: user, tag: "#大阪市長選")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.tag)
        end
      end
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
