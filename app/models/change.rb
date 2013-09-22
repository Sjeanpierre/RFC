class Change < ActiveRecord::Base
  has_one :priority
  has_one :status
  has_one :system
  has_one :type
end
