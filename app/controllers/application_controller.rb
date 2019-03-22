require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  protect_from_forgery with: :exception

  before_action :gon_user, unless: :devise_controller?

  def check_author(item = nil)
    item ||= instance_variable_get("@#{resource_type}")
    return if current_user.author_of?(item)
    flash[:notice] = "You need to be an author of the #{resource_type}"
    redirect_back(fallback_location: root_url)
  end

  # private?

  def model_klass
    controller_name.classify.constantize
  end

  def resource_type
    controller_name.singularize
  end

  private

  def gon_user
    gon.user_id = current_user&.id
  end
end
