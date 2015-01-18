class SettingsController < ApplicationController
  def settings
    @systems = System.all
  end


  def add_resource
    if params[:resource] == 'product'
      Product.add_new(params[:product_country],params[:product_name])
    elsif params[:resource] == 'system'
      System.add_new(params[:system_category],params[:system_name])
    end
    render nothing: true, status: 204
  rescue ActiveRecord::RecordInvalid => error
    render :json => {:error => error.message}, :status => 400
  end

  def render_settings_area
    render :partial => "settings/#{params[:settings_area]}"
  end
end