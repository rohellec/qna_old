module Serialized
  extend ActiveSupport::Concern

  def check_resource_found
    item = instance_variable_get "@#{resource_type}"
    render_not_found unless item
  end

  def render_json_with_message(item = nil, message = nil)
    item    ||= instance_variable_get "@#{resource_type}"
    message ||= t(".message")
    render json: Hash[resource_type, item, :message, message]
  end

  def render_not_found
    render plain: t("http_error.not_found"), status: :not_found
  end

  def render_errors(item = nil)
    item ||= instance_variable_get "@#{resource_type}"
    render json: item.errors.full_messages, status: :forbidden
  end

  def render_unprocessable_with_message(message = nil)
    message ||= t(".unprocessable", default: :"http_error.unprocessable_entity")
    render plain: message, status: :unprocessable_entity
  end
end
