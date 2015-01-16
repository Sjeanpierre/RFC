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
end
