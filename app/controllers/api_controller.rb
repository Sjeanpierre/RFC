class ApiController < ApplicationController
  skip_before_filter :require_login, :current_user
  before_filter :authenticate_api_user


  def authenticate_api_user
    render :status => 403, :text => 'API credentials invalid' unless valid_credentials?(request.headers[:HTTP_ACCESS_KEY],request.headers[:HTTP_SECRET_KEY])
  end

  def valid_credentials?(access_key,secret_key)
    if access_key == ENV['API_USER_ACCESS_KEY'] && secret_key == ENV['API_USER_SECRET_KEY']
      true
    else
      false
    end
  end


  def list
    @changes = Change.includes(:creator,:change_type,:impact,:priority,:status,:system).pending
    formatted_for_json = @changes.map { |change| change.json_formatted }
    render :json => formatted_for_json
  end

  def show
    @change = Change.includes(:creator,:change_type,:impact,:priority,:status,:system).find(params[:id])
    formatted_for_json = @change.json_formatted
    render :json => formatted_for_json
  end

end

