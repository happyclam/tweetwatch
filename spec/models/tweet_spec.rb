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
end
