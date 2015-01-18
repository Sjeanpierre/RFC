class Status < ActiveRecord::Base
  has_one :change


  def self.for_seed
    statuses = all
    statuses.reject {|status| %w(approved completed).include?(status.name)}
  end

  def self.list_for_dropdown
    all.map { |resource| {:id => resource.id, :text => resource.name.capitalize} }
  end

end
