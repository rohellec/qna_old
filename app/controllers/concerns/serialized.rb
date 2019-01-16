module Serialized
  extend ActiveSupport::Concern

  def check_resource_found
    item = instance_variable_get "@#{resource_type}"
    render_not_found unless item
  end

  def render_json_with_message(item = nil)
    item ||= instance_variable_get "@#{resource_type}"
    render json: Hash[resource_type, item, :message, t(".message")]
  end

  def render_not_found
    render plain: t("http_error.not_found"), status: not_found
  end

  def respond_errors(item = nil)
    item ||= instance_variable_get "@#{resource_type}"
    render json: item.errors.full_messages, status: :forbidden
  end

  def respond_unprocessable_with_message(message = nil)
    message ||= t(".unprocessable")
    respond_to do |format|
      format.json { render json: message, status: :unprocessable_entity }
      format.html do
        flash[:notice] = message
        redirect_back(fallback_location: root_url)
      end
    end
  end

  private

  def model_klass
    controller_name.classify.constantize
  end

  def resource_type
    controller_name.singularize
  end
end
