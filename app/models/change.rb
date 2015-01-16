class Change < ActiveRecord::Base
  acts_as_commentable
  include MailApi
  include PrintHandler
  has_many :events
  belongs_to :priority
  belongs_to :status
  belongs_to :system
  belongs_to :change_type
  belongs_to :impact
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  has_many :approvers
  has_many :users, through: :approvers
  has_many :attachments
  validates_presence_of :title, :priority, :system, :status, :change_type, :summary, :rollback, :creator
  after_update :track_changes
  after_create :track_create


  RESOURCES = {:impact => Impact, :status => Status, :system => System, :changeType => ChangeType, :priority => Priority, :change_type => ChangeType}

  def self.create_change_request(params, current_user)
    approvers = params[:approvers].reject { |approver| approver.blank? }
    new_change = Change.new(
        :title => params[:title],
        :priority_id => params[:priority],
        :system_id => params[:system],
        :status_id => params[:status],
        :change_type_id => params[:change_type],
        :impact_id => params[:impact],
        :change_date => Date.strptime(params[:change_date], '%m/%d/%Y'),
        :summary => params[:summary],
        :rollback => params[:rollback],
        :creator => current_user
    )
    approvers.each do |approver|
      new_change.approvers.build(:user_id => approver)
    end
    new_change
  end

  def self.mark_approved(change_id, approver_id)
    change = find(change_id)
    approval_record, can_approve = change.approval_details(approver_id)
    if can_approve
      approval_record.approved = true
      approval_record.save
      change.status = Status.find_by(:name => 'approved')
      change.save
      change.create_event('Approved', "approved by #{User.find(approver_id).name}")
      true
    else
      false
    end
  end

  def self.pending
    joins(:status).where(:statuses => {:name => %w(new pending approved)}).order(:id => :desc)
  end

  def self.mark_complete(change_id, current_user)
    change = find(change_id)
    #if current_user == change.creator
    change.status = Status.find_by(:name => 'completed')
    change.save
    change.create_event('Completed', "marked completed by #{current_user.name}")
    true
    #else
    #false
    #end
  end

  def self.update_value(params)
    change = find(params[:id])
    if params[:pk]
      if params[:resource] == 'change_date'
        change.change_date = Date.strptime(params[:value], '%m/%d/%Y')
      elsif params[:resource] == 'title'
        change.title = params[:value]
      else
        resource_class = RESOURCES[params[:resource].to_sym]
        value = resource_class.find(params[:value])
        change.send("#{params[:resource].to_s}=", value)
      end
    else
      change.send("#{params[:resource].to_s}=", params[:value])
    end
    change.save
  end

  def self.mark_rejected(change_id, approver_id)
    change = find(change_id)
    _, can_approve = change.approval_details(approver_id)
    if can_approve
      change.status = Status.find_by(:name => 'rejected')
      change.save
      change.create_event('Rejected', "rejected by #{User.find(approver_id).name}")
      true
    else
      false
    end
  end

  #todo refector for more resource types
  def self.add_resource_item(resource_type, resource_name,resource_category=nil)
    raise('invalid resource') unless RESOURCES.has_key?(resource_type.to_sym)
    resource_class = RESOURCES[resource_type.to_sym]
    if resource_class == System
      System.add_new(resource_category,resource_name)
    else
      resource_class.find_or_create_by(:name => resource_name.downcase)
    end
  end

  def self.print(ids)
    return '<h1>No Items Selected</h1>' if ids.blank?
    changes = Change.includes(:creator, :approvers, :attachments, :change_type, :impact, :priority, :status, :system, {:comment_threads => :user}, {:approvers => :user}, :events).where(:id => ids)
    p = PrintHandler::View.new(changes)
    p.prepare
  end

  def recipients

  end

  def drop_down_items
    %w(priority status system change_type impact)
  end

  def approval_details(user_id)
    approval_record = approvers.where('user_id' => user_id)
    [approval_record.first, approval_record.exists?]
  end

  def can_approve?(user_id)
    approvers.exists?(:user_id => user_id)
  end

  def can_complete?(user)
    creator == user
  end

  def editable?
    if %w(approved completed aborted).include?(status.name)
      false
    else
      true
    end
  end

  def json_formatted
    {
        :id => id,
        :created_by => creator.name,
        :created_date => created_at.to_s(:long),
        :due_date => expected_change_date,
        :title => title,
        :type => change_type.name,
        :impact => impact.name,
        :priority => priority.name,
        :status => status.name,
        :system => "#{system.category}-#{system.name}"
    }
  end


  def approved_by
    self.approvers.where(:approved => true).first.user
  end

  # @param [Symbol] resource
  def self.agg_count(resource, open=nil)
    counts = []
    values = group(resource).count
    values.each { |key, count| counts.push({:value => count, :label => key.name, }) }
    counts
  end

  def self.get_resource_items(resource_type)
    raise("#{resource_type} is an invalid resource") unless RESOURCES.has_key?(resource_type.to_sym)
    resource_class = RESOURCES[resource_type.to_sym]
    resource_class.all.map { |resource| resource.name.capitalize }
  end

  def self.get_item_list(resource_type)
    raise("#{resource_type} is an invalid resource") unless RESOURCES.has_key?(resource_type.to_sym)
    resource_class = RESOURCES[resource_type.to_sym]
    if resource_type == 'system'
      grouped_data = resource_class.all.to_a.group_by { |item| item.category }.each do |_, systems|
        systems.map! { |system| {:id => system.id, :text => system.name.upcase} }
      end
      grouped_data.map { |system_category, system_name_array| {:text => system_category.titleize, :children => system_name_array} }
    else
      resource_class.all.map { |status| {:id => status.id, :text => status.name.capitalize} }
    end
  end

  def create_event(event_type, event_details)
    self.events.create(
        :event_type => event_type,
        :details => event_details
    )
  end

  def track_changes
    changes = self.changes
    text_fields = changes.keys.select { |field| %w(summary rollback).include?(field) }
    local_fields = changes.keys.select { |field| %w(change_date title).include?(field) }
    changed_associated_fields = changes.keys.reject { |field| %w(status_id change_date updated_at summary rollback title).include?(field) }
    changed_associated_fields.each do |field|
      klass = Change.reflections.select { |_, v| v.foreign_key == field }.values.first.class_name.constantize
      self.create_event('Updated', "#{klass.model_name.human.titleize} updated from #{klass.find(changes[field][0]).name.capitalize} to #{klass.find(changes[field][1]).name.capitalize} ")
    end
    text_fields.each do |field|
      self.create_event('Updated', "#{field.capitalize} field updated!")
    end
    local_fields.each do |field|
      if field == change_date
        self.create_event('Updated', "#{field.humanize.titleize} updated from #{changes[field][0].try(:strftime, '%m/%d/%Y')} to #{changes[field][1].try(:strftime, '%m/%d/%Y')}")
      else
        self.create_event('Updated', "#{field.humanize.titleize} updated from #{changes[field][0]} to #{changes[field][1]}")
      end
    end
  end

  def track_create
    self.create_event('Created', "created by #{self.creator.name}")
  end

end
