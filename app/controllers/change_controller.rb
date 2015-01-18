class ChangeController < ApplicationController
  def show
    @change = Change.includes({:comment_threads => :user},{:approvers => :user},:product, :events).find(params[:id])
  end

  def print_data
    html = Change.print(params[:cids])
    render :text => html
  end

  def print_report; end

  def new
    @change = Change.new
  end

  def index
    @changes = Change.includes(:status,:priority,:creator) #Change.all
  end

  def report
    @changes = Change.includes(:creator,:change_type,:impact,:priority,:status,:system,:product)
  end

  def create
    creator = current_user
    change = Change.create_change_request(params[:change],creator)
    if change.save
      redirect_to change_path(change)
    else
      @change = change
      render 'new'
    end
  end

  def update
    Change.update_value(params)
    render :status => 200, :text => 'Success'
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

  def download
    @download = Attachment.find(params[:aid])
    render :json => {:url => @download.attachment.expiring_url(10)}
  end

  def count
   render :json => Change.agg_count(params[:resource].to_sym)
  end

  def render_partial
    @change = Change.find(params[:id])
    render :partial => "#{params[:partial]}"
  end


  def get_resource
    values = Change.get_resource_items(params[:resource])
    render :json => values
  end

  def get_resources
    values = Change.get_item_list(params[:resource])
    render :json => values
  end


  private

  def upload_params
    params.permit(:attachment, :attachment_file_name)
  end

end
