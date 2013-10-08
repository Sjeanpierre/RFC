class Approver < ActiveRecord::Base
  belongs_to :user
  belongs_to :change
end
