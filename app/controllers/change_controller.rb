class ChangeController < ApplicationController
  def show
  end

  def new
    @change = Change.new
  end

  def create
    #if params[:priority] && params[:status] && params[:system] && params[:type] && params[:impact]
      Change.create_change_request(params[:change])
    render :text => 'good'
    #else
    #  redirect_to new_change_path, :notice => 'missing values'
    #end
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
