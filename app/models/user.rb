class User < ActiveRecord::Base
  has_many :services
  has_many :approvers
  has_many :changes, through: :approvers
  has_many :changes, :foreign_key => 'created_by'


  def initials
    first,last = name.split(' ')
    "#{first[0].upcase}#{last[0].upcase}"
  end
end
