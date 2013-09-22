class ChangeController < ApplicationController
  def show
  end

  def new
    @change = Change.new
    @statuses = Status.all
  end
end
