class Status < ActiveRecord::Base
  has_one :change


  def self.for_seed
    statuses = all
    statuses.reject {|status| %w(approved completed).include?(status.name)}
  end
end
