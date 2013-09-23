class ChangeController < ApplicationController
  def show
  end

  def new
    @change = Change.new
  end

  def create
    Change.create_change_request(params)
  end
end
