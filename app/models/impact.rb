class Impact < ActiveRecord::Base
  has_one :change

  def self.list_for_dropdown
    all.map { |resource| {:id => resource.id, :text => resource.name.capitalize} }
  end
end
