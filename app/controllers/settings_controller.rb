class SettingsController < ApplicationController
  def settings
    @systems = System.all
  end
end