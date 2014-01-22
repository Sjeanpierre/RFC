class Change < ActiveRecord::Base
  include MailApi
  belongs_to :priority
  belongs_to :status
  belongs_to :system
  belongs_to :change_type
  belongs_to :impact
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  has_many :approvers
  has_many :users, through: :approvers

  RESOURCES = { :impact => Impact, :status => Status, :system => System, :changeType => ChangeType, :priority => Priority }

  def self.create_change_request(params, current_user)
    priority_id = Priority.find_or_create_by(:name => params[:priority].downcase).id
    status_id = Status.find_or_create_by(:name => params[:status].downcase).id
    system_id = System.find_or_create_by(:name => params[:system].downcase).id
    change_type_id = ChangeType.find_or_create_by(:name => params[:change_type].downcase).id
    impact_id = Impact.find_or_create_by(:name => params[:impact].downcase).id
    approvers = params[:approvers].reject { |approver| approver.blank? }
    new_change = Change.create(
        :title => params[:title],
        :priority_id => priority_id,
        :system_id => system_id,
        :status_id => status_id,
        :change_type_id => change_type_id,
        :impact_id => impact_id,
        :change_date => Date.strptime(params[:change_date], '%m/%d/%Y'),
        :summary => params[:summary],
        :rollback => params[:rollback],
        :creator => current_user
    )
    approvers.each do |approver|
      new_change.approvers.build(:user_id => approver)
    end
    new_change.save!
    MailApi.send_message('new', new_change) #TODO add delayed job
    new_change
  end

  def self.add_resource_item(resource_type, resource_name)
    raise('invalid resource') unless RESOURCES.has_key?(resource_type.to_sym)
    resource_class = RESOURCES[resource_type.to_sym]
    resource_class.find_or_create_by(:name => resource_name.downcase)
  end

  def approval_details(user_id)
    approval_record = approvers.where('user_id' => user_id)
    [approval_record.first, approval_record.exists?]
  end

  def self.mark_approved(change_id, approver_id)
    change = find(change_id)
    approval_record, can_approve = change.approval_details(approver_id)
    if can_approve
      approval_record.approved = true
      approval_record.save
      change.status = Status.find_by(:name => 'approved')
      change.save
      true
    else
      false
    end
  end


  def self.mark_rejected(change_id, approver_id)
    change = find(change_id)
    _, can_approve = change.approval_details(approver_id)
    if can_approve
      change.status = Status.find_by(:name => 'rejected')
      change.save
      true
    else
      false
    end
  end

  def self.get_resource_items(resource_type)
    raise("#{resource_type} is an invalid resource") unless RESOURCES.has_key?(resource_type.to_sym)
    resource_class = RESOURCES[resource_type.to_sym]
    resource_class.all.map { |resource| resource.name.capitalize }
  end
end
