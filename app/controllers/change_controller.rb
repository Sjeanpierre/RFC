class ChangeController < ApplicationController
  def show
    @change = Change.includes({:comment_threads => :user},{:approvers => :user}, :events).find(params[:id])
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

  def comment
    @change = Change.find(params[:id])
    @comment = Comment.build_from(@change, current_user.id,params[:subject], params[:comment] )
    @comment.save!
    render :partial => 'comments'
  end

  def approve
    success = Change.mark_approved(params[:id], current_user.id)
    if success
      render :status => 200, :text => "successfully approved changeID #{params[:id]}"
    else
      render :status => 403, :layout => false
    end
  end

  def add_attachment
    @attachment = Change.find(params[:id]).attachments.new(upload_params)
    @attachment.save
    render :status => 200, :text => 'success'
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

  private

  def upload_params
    params.permit(:attachment, :attachment_file_name)
  end

end
