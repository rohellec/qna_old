module Voted
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_voting,  only: [:up_vote, :down_vote]
    before_action :set_votable,          only: [:up_vote, :down_vote, :delete_vote]
    before_action :check_votable_author, only: [:up_vote, :down_vote]
    before_action :check_author_vote,    only: [:up_vote, :down_vote]
  end

  def up_vote
    current_user.up_vote(@votable)
    respond_voting_with_json(message: :create_vote)
  end

  def down_vote
    current_user.down_vote(@votable)
    respond_voting_with_json(message: :create_vote)
  end

  def delete_vote
    vote = current_user.delete_vote(@votable)
    if vote.present?
      respond_voting_with_json(message: :delete_vote)
    else
      respond_unprocessable_with_message t("controllers.voted.not_removable")
    end
  end

  private

  def authenticate_voting
    return if user_signed_in?
    message = voted_response_message(:not_authenticated_error)
    respond_unprocessable_with_message(message)
  end

  def check_votable_author
    return unless current_user.author_of?(@votable)
    message = voted_response_message(:votable_author_error)
    respond_unprocessable_with_message(message)
  end

  def check_author_vote
    return unless @votable.voted_by?(current_user)
    message = voted_response_message(:already_voted_error)
    respond_unprocessable_with_message(message)
  end

  def set_votable
    @votable = model_klass.find(params[:id])
  end

  def voted_response_message(message_key)
    lookup_key = "controllers.voted.#{message_key}"
    t(lookup_key, votable_type: resource_type)
  end

  def respond_voting_with_json(options)
    message = voted_response_message(options[:message])
    render json: {
      votable_id: @votable.id,
      resource:   controller_name,
      rating:     @votable.vote_rating,
      message:    message
    }
  end
end
