class ChangeController < ApplicationController
  def show
  end

  def new
    @change = Change.new
  end

  def create
    Change.create_change_request(params)
    render :json => '', :status => 200
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
