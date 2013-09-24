class Change < ActiveRecord::Base
  has_one :priority
  has_one :status
  has_one :system
  has_one :change_type
  has_one :impact

  def self.create_change_request(params)
    priority_id = Priority.find_or_create_by(:name => params[:priority].downcase).id
    status_id = Status.find_or_create_by(:name => params[:status].downcase).id
    system_id = System.find_or_create_by(:name => params[:system].downcase).id
    change_type_id = ChangeType.find_or_create_by(:name => params[:type].downcase).id
    impact_id = Impact.find_or_create_by(:name => params[:impact].downcase).id
    Change.create(
        :title => params[:summary],
        :priority_id => priority_id,
        :system_id => system_id,
        :status_id => status_id,
        :change_type_id => change_type_id,
        :impact_id => impact_id,
        :summary => params[:summary],
        :rollback => params[:rollback]
    )
  end
end
