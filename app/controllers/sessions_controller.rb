class SessionsController < ApplicationController
  skip_before_filter :require_login
  def new; end

  def destroy
    logout!
    redirect_to root_url
  end
end
