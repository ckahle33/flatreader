class User < ActiveRecord::Base
  has_many :user_sources
  has_many :sources, through: :user_sources
  has_secure_password
end
