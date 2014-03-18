require 'digest/sha1'
require 'pbkdf2'
class User < ActiveRecord::Base
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :login, :presence => true, :format => { :with => email_regex }, :uniqueness => true
  #validates_confirmation_of :password
  #attr_accessor :password

  #validates_presence_of :password

  before_create :encrypt_password
  before_create :set_uploadsleft, :set_plan

  def self.authenticated?(login, password)
    #pwd = Digest::SHA1.hexdigest(password.to_s)
    #User.find_by_login_and_hashed_password(login, pwd)

    #if user && user.hashed_password == self.encrypt(password, user.salt)

    #end
    user = User.find_by_login(login)
    if user && user.hashed_password == self.encrypt(password, user.salt)
      #pwd = self.encrypt(password, user.salt)
      #User.find_by_login_and_hashed_password(login, pwd)
      return user
    end
  end

  def self.decrement_remaininguploads(user)
    User.where('id = ? AND plan = ?', user, 0).update_all("uploadsleft = uploadsleft - 1")
  end

  def self.reset_remaininguploads
    User.where('uploadsleft < 10').update_all("uploadsleft = 10")
  end

  def self.encrypt(clear_text, salt)
    derived_key = PBKDF2.new do |key|
      key.password = clear_text
      key.salt = salt
      key.iterations = 10000
    end
    return derived_key.hex_string
  end

  def self.make_salt
    return SecureRandom.hex
  end

  private

  def encrypt_password
    unless self.hashed_password.blank?
      salt = SecureRandom.hex
      self.salt = salt
      self.hashed_password = User.encrypt(self.hashed_password.to_s, salt)
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
