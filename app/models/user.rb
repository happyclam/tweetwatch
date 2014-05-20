# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#  c_key           :string(255)
#  c_secret        :string(255)
#  a_key           :string(255)
#  a_secret        :string(255)
#  tweets_count    :integer          default(0)
#

class User < ActiveRecord::Base
  has_one :serv, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :tweets, :class_name => "Tweet", :foreign_key => "own_user_id", :dependent => :destroy
  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates(:name, presence: true)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}
  validates :password, length: { minimum: 6 }
  has_secure_password
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
    Track.where("user_id = ?", id)
  end

  private
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

end
