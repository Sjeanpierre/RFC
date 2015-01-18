class System < ActiveRecord::Base
  has_one :change
  validates_presence_of :category, :name
  validates_uniqueness_of :name, :scope => :category
  before_create :downcase_attributes


  def self.add_new(category,name)
    system = new
    system.category = category
    system.name = name
    system.save!
  end

  def downcase_attributes
    self.category.downcase!
    self.name.downcase!
  end

  def self.list_for_dropdown
    grouped_by_category = all.to_a.group_by { |system| system.category }
    grouped_by_category.each do |_, system_list|
      system_list.map! { |system| {:id => system.id, :text => system.name.upcase} }
    end
    grouped_by_category.map { |system_category, system_name_array| {:text => system_category.titleize, :children => system_name_array} }
  end

end
