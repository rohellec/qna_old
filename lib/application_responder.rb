class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  Responders::FlashResponder.flash_keys = [:success, :failure]

  def to_json
    set_flash_message! if set_flash_message?
    if !get? && has_errors? && !response_overridden?
      display_errors
    elsif response_overridden?
      default_render
    else
      json_behaviour
    end
  end

  protected

  def controller_action_message
    controller_scope = controller.controller_path.split('/').join('.')
    action_scope = "#{controller_scope}.#{controller.action_name}"
    :"#{action_scope}.message"
  end

  def display_json(given_options = {})
    item = if options[:include]
             associations = options.delete(:include)
             resource.as_json(root: true, include: associations)
           else
             resource.as_json(root: true)
           end
    options[:json] = item.merge!(message: success_message)
    controller.render given_options.merge!(options)
  end

  def json_behaviour
    if post?
      display_json status: :created, location: api_location
    else
      display_json
    end
  end

  def json_resource_errors
    { errors: resource.errors.full_messages }
  end

  def set_flash_now?
    @flash_now == true || format == :js || format == :json ||
      (default_action && (has_errors? ? @flash_now == :on_failure : @flash_now == :on_success))
  end

  def success_message
    status = Responders::FlashResponder.flash_keys.first
    controller.flash[status] || Responders::FlashResponder.helper.t(controller_action_message)
  end
end
