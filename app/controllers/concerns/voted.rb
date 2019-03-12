module Voted
  extend ActiveSupport::Concern

  include Serialized

  included do
    before_action :authenticate_voting,  only: [:up_vote, :down_vote]
    before_action :set_votable,          only: [:up_vote, :down_vote, :delete_vote]
    before_action :check_votable_author, only: [:up_vote, :down_vote]
    before_action :check_vote_author,    only: [:up_vote, :down_vote]
  end

  def up_vote
    current_user.up_vote(@votable)
    render json: voted_json
  end

  def down_vote
    current_user.down_vote(@votable)
    render json: voted_json
  end

  def delete_vote
    vote = current_user.delete_vote(@votable)
    if vote.present?
      render json: voted_json
    else
      message = voted_response_message(:not_removable)
      render_unprocessable_with_message(message)
    end
  end

  private

  def authenticate_voting
    return if user_signed_in?
    message = voted_response_message(:not_authenticated_error)
    render_unprocessable_with_message(message)
  end

  def check_votable_author
    return unless current_user.author_of?(@votable)
    message = voted_response_message(:votable_author_error)
    render_unprocessable_with_message(message)
  end

  def check_vote_author
    return unless @votable.voted_by?(current_user)
    message = voted_response_message(:already_voted_error)
    render_unprocessable_with_message(message)
  end

  def set_votable
    @votable = model_klass.find(params[:id])
  end

  def voted_response_message(message_key = action_name)
    lookup_key = "controllers.voted.#{message_key}"
    t(lookup_key, votable_type: resource_type)
  end

  def voted_json
    {
      votable_id:   @votable.id,
      votable_type: resource_type,
      rating:       @votable.vote_rating,
      message:      voted_response_message
    }
  end
end
