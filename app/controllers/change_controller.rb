class ChangeController < ApplicationController
  def show
    @change = Change.find(params[:id])
  end

  def new
    @change = Change.new
  end

  def index
    @changes = Change.all
  end

  def create
    change = Change.create_change_request(params[:change])
    redirect_to change_path(change)
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
