module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title.to_s }
  end

  def yield_or_default(section, default = '')
    content_for?(section) ? content_for(section) : default
  end

  def active_nav(actionName)
    if params[:action] == actionName
      'active'
    end
  end

  def active_setting_nav(setting_area)
    if params[:setting_area] == setting_area
      'active'
    end
  end
end
