class SessionsController < ApplicationController
  skip_before_filter :require_login
  def new
    redirect_to root_path if logged_in?
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
