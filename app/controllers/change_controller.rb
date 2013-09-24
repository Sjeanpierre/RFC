class ChangeController < ApplicationController
  def show
  end

  def new
    @change = Change.new
    @change_types = ChangeType.all
  end

  def create
    #Change.create_change_request(params)
    render nothing:true, status: 200
  end
end
