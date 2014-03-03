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

end
