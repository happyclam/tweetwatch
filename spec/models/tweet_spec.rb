# == Schema Information
#
# Table name: tweets
#
#  id                     :integer          not null, primary key
#  user_id                :integer          default(0), not null
#  user_name              :text             not null
#  user_screen_name       :text             not null
#  user_image             :text
#  user_description       :text
#  user_text              :text
#  post_hashtags          :text
#  status_id              :integer
#  reply_status_id        :integer
#  reply_user_id          :integer
#  reply_user_screen_name :text
#  created_at             :date
#  updated_at             :date
#

require 'spec_helper'

describe Tweet do
#  pending "add some examples to (or delete) #{__FILE__}"
end
