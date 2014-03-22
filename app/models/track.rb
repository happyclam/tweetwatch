# == Schema Information
#
# Table name: tracks
#
#  id         :integer          not null, primary key
#  tag        :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Track < ActiveRecord::Base
  belongs_to :user
  default_scope -> {order('created_at DESC')}
  validates :user_id, presence: true
  validates :tag, presence: true, length: {maximum: 139}

end
