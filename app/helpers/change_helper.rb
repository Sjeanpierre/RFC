module ChangeHelper

  def approver_section(change)
    status_name = change.status.name
    if status_name == 'approved' && change.can_complete?(current_user)
      render :partial => 'change/post_approval'
    else
      unless %w(completed aborted rejected approved).include?(status_name)
        if change.can_approve?(current_user.id)
          render :partial => 'change/approval_buttons'
        end
      end
    end
  end

  def approver_list(change)
    status_name = change.status.name
    unless %w(approved completed).include?(status_name)
      render :partial => 'change/approvers'
    end
  end

  def change_text(change)
    if change.editable?
      render :partial => 'change/change_text'
    else
      render :partial => 'change/change_text_locked'
    end
  end

  def mixer_classes(change)
    status = change.status.id
    system = change.system.id
    priority = change.priority.id
    creator = change.creator.id
    impact = change.impact.id
    change_type = change.change_type.id
    "status-#{status} impact-#{impact} system-#{system} changetype-#{change_type} priority-#{priority} user-#{creator}"
  end

  def mixer_select_values(resource)
    resource_class = resource.class.to_s.downcase
    resource_id = resource.id
    ".#{resource_class}-#{resource_id}"
  end

  def build_option_group(resource,group_method)
    resource.all.group_by {|item| item.send(group_method.to_sym)}
  end

  def icon_processor(status)
    case status.downcase
      when 'approved'
        return 'fa-thumbs-o-up'
      when 'new'
        return 'fa-bolt'
      when 'rejected'
        return 'fa-thumbs-o-down'
      when 'aborted'
        return 'fa-exclamation'
      when 'completed'
        return 'fa-check-square-o'
      when 'pending'
        return 'fa-clock-o'
      else
        return 'fa-question'
    end
  end

  def color_processor(status)
    case status.downcase
      when 'approved'
        return 'bg-green'
      when 'new'
        return 'bg-blue'
      when 'rejected'
        return 'bg-red'
      when 'aborted'
        return 'bg-red'
      when 'completed'
        return 'bg-purple'
      when 'pending'
        return 'bg-orange'
      else
        return 'bg-orange'
    end
  end

  def priority_color_processor(priority)
    case priority.downcase
      when 'high'
        return 'bg-red'
      when 'medium'
        return 'bg-orange'
      when 'low'
        return 'bg-green'
      else
        return 'bg-purple'
    end
  end

  def mixer_date(change)
    change.created_at.strftime('%Y%m%d')
  end


end
