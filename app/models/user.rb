class User < ActiveRecord::Base
  has_many :services
  has_many :approvers
  has_many :changes, through: :approvers
end
