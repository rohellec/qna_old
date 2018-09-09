class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

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
