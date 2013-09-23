class Change < ActiveRecord::Base
  has_one :priority
  has_one :status
  has_one :system
  has_one :change_type
  has_one :impact

  def self.create_change_request(params)
    priority_id = Priority.find_or_create_by(:name => params[:priority]).id
    status_id = Status.find_or_create_by(:name => params[:status]).id
    system_id = System.find_or_create_by(:name => params[:system]).id
    type_id = Type.find_or_create_by(:name => params[:type]).id
    impact_id = Impact.find_or_create_by(:name => params[:impact]).id
    Change.create(
        :title => params[:summary],
        :priority_id => priority_id,
        :system_id => system_id,
        :status_id => status_id,
        :type_id => type_id,
        :impact_id => impact_id,
        :summary => params[:summary],
        :rollback => params[:rollback]
    )
  end
end
