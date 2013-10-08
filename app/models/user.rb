class User < ActiveRecord::Base
  has_many :services
  has_many :approvers
  has_many :changes, through: :approvers
  has_many :changes, :foreign_key => 'created_by'
end
