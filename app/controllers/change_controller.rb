class ChangeController < ApplicationController
  def show
  end

  def new
    @change = Change.new
  end

  def create
    Change.create_change_request(params)
  end

  def add_resource
    Change.add_resource_item(params[:resource],params[:value])
    render nothing:true, status: 200
  end
end
