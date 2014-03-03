class Track < ActiveRecord::Base
  belongs_to :user
  default_scope -> {order('created_at DESC')}
  validates :user_id, presence: true
  validates :tag, presence: true, length: {maximum: 139}

end
