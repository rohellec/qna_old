module ApplicationHelper
  def correct_user?(user)
    user_signed_in? && current_user == user
  end
end
