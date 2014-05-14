# == Schema Information
#
# Table name: servs
#
#  id         :integer          not null, primary key
#  track      :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Serv < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :track, length: {maximum: TAG_MAX_LENGTH}

  state_machine :status, :initial => :down do
    state :down, value: DOWN
    state :prepared, value: PREPARED
    state :storing, value: STORING

    event :start do
      transition :down => :prepared
    end
    event :store do
      transition :prepared => :storing
    end
    event :stop do
      transition [:storing, :prepared] => :down
    end
  end
end
