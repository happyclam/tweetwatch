# == Schema Information
#
# Table name: tweets
#
#  id                     :integer          not null, primary key
#  user_id                :integer          default(0), not null
#  user_name              :string(255)      not null
#  user_screen_name       :string(255)      not null
#  user_image             :string(255)
#  user_description       :text
#  user_text              :text
#  post_hashtags          :string(255)
#  status_id              :integer
#  reply_status_id        :integer
#  reply_user_id          :integer
#  reply_user_screen_name :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  own_user_id            :integer
#

require 'spec_helper'

describe Tweet do
#  pending "add some examples to (or delete) #{__FILE__}"
  let(:user) { FactoryGirl.create(:user) }
  before do
    @tweet = user.tweets.build(user_id: 1527226446,
                               user_name: "検索ポータルサイト", 
                               user_screen_name: "hallojp",
                               user_image: "http://pbs.twimg.com/profile_images/378800000010083880/448205ab46471ca4d73037203e379cec_normal.png",
                               user_description: "スマートフォンに特化した総合検索ポータルサイト。",
                               user_text: "http://t.co/rbumvjtpAj\n\n小保方氏は「論文を撤回するつもりはない」　弁護士が明かす\n\n#STAP細胞　#小保方",
                               post_hashtags: "{\"text\"=>\"STAP細胞\", \"indices\"=>[54, 61]},{\"text\"=>\"小保方\", \"indices\"=>[62, 66]}",
                               status_id: 468628337103888385,
                               reply_status_id: 0,
                               reply_user_id: 0,
                               reply_user_screen_name: "")
  end
  subject { @tweet }

  it { should respond_to(:own_user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user_text) }
  it { should respond_to(:post_hashtags) }
  its(:user) { should eq user }

  it {should be_valid}
  describe "when own_user_id is not present" do
    before { @tweet.own_user_id = nil }
    it { should_not be_valid }
  end

end
