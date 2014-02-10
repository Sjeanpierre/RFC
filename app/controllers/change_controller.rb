class ChangeController < ApplicationController
  def show
    @change = Change.includes({:approvers => :user}, :approvers).find(params[:id])
  end

  def new
    @change = Change.new
  end

  def index
    @changes = Change.includes(:status,:priority,:creator) #Change.all
  end

  def create
    creator = current_user || User.find(4)
    change = Change.create_change_request(params[:change],creator)
    redirect_to change_path(change)
  end

  def approve
    success = Change.mark_approved(params[:id], current_user.id)
    if success
      render :status => 200, :text => "successfully approved changeID #{params[:id]}"
    else
      render :status => 403, :layout => false
    end
  end

  def reject
    success = Change.mark_rejected(params[:id], current_user.id)
    if success
      render :status => 200, :text => "successfully rejected changeID #{params[:id]}"
    else
      render :status => 403, :layout => false
    end
  end

  def complete
    success = Change.mark_complete(params[:id], current_user)
    if success
      render :status => 200, :text => "successfully rejected changeID #{params[:id]}"
    else
      render :status => 403, :layout => false
    end
  end

  def count
   render :json => Change.agg_count(params[:resource].to_sym)
  end


  def add_resource
    Change.add_resource_item(params[:resource],params[:value])
    render nothing:true, status: 200
  end

  def get_resource
    values = Change.get_resource_items(params[:resource])
    render :json => values
  end
end
