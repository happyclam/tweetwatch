class Serv < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :track, length: {maximum: TAG_MAX_LENGTH}

  state_machine :status, :initial => :down do
    state :down
    state :prepared
    state :storing

    event :start do
      transition :down => :prepared
    end
    event :store do
      transition :prepared => :storing
    end
    event :stop do
      transition [:down, :prepared] => :down
    end
  end
end
