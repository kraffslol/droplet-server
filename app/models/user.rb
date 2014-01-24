require 'digest/sha1'
class User < ActiveRecord::Base
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :login, :presence => true, :format => { :with => email_regex }, :uniqueness => true
  validates_confirmation_of :password
  attr_accessor :password

  before_save :encrypt_password
  before_create :set_uploadsleft, :set_plan

  def self.authenticated?(login, password)
    pwd = Digest::SHA1.hexdigest(password.to_s)
    User.find_by_login_and_hashed_password(login, pwd)
  end

  def self.decrement_remaininguploads(user)
    User.where('id = ? AND plan = ?', user, 0).update_all("uploadsleft = uploadsleft - 1")
  end

  def self.reset_remaininguplods
    User.where('uploadsleft < 10').update_all("uploadsleft = 10")
  end

  private

  def encrypt_password
    unless self.password.blank?
      self.hashed_password = Digest::SHA1.hexdigest(self.password.to_s)
      self.password = nil
    end
    return true
  end

  def set_uploadsleft
    self.uploadsleft = 10
  end

  def set_plan
    self.plan = 0
  end
end
