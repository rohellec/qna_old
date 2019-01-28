class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def check_author(item = nil)
    item ||= instance_variable_get("@#{resource_type}")
    return if current_user.author_of?(item)
    flash[:notice] = "You need to be an author of the #{resource_type}"
    redirect_back(fallback_location: root_url)
  end

  def model_klass
    controller_name.classify.constantize
  end

  def resource_type
    controller_name.singularize
  end

  def respond_unprocessable_with_message(message)
    respond_to do |format|
      format.json { render json: message, status: :unprocessable_entity }
      format.html do
        flash[:notice] = message
        redirect_back(fallback_location: root_url)
      end
    end
  end
end
