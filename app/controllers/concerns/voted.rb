module Voted
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_voting, only: [:up_vote, :down_vote]
    before_action :set_votable, only: [:up_vote, :down_vote, :delete_vote]
    before_action :check_votable, only: [:up_vote, :down_vote]
  end

  def up_vote
    @vote = current_user.up_vote(@votable)
    success = "Your vote has been counted"
    fail    = "You have already up voted this #{resource_type}"
    respond_vote_with_json(success: success, fail: fail)
  end

  def down_vote
    @vote = current_user.down_vote(@votable)
    success = "Your vote has been counted"
    fail    = "You have already down voted this #{resource_type}"
    respond_vote_with_json(success: success, fail: fail)
  end

  def delete_vote
    @vote = current_user.delete_vote_from(@votable)
    success = "Your vote has been successfully deleted"
    fail    = "You haven't voted for this #{resource_type}"
    respond_vote_with_json(success: success, fail: fail)
  end

  private

  def authenticate_voting
    return if user_signed_in?
    message = "You need to sign in before you can vote"
    respond_unprocessable_entity message
  end

  def check_votable
    return unless current_user.author_of?(@votable)
    message = "You can't vote for your own #{resource_type}"
    respond_unprocessable_entity message
  end

  def model_klass
    controller_name.classify.constantize
  end

  def resource_type
    controller_name.singularize
  end

  def respond_vote_with_json(messages)
    respond_to do |format|
      if @vote
        format.json { render json: vote_response(messages[:success]) }
      else
        format.json { render json: messages[:fail], status: :unprocessable_entity }
      end
    end
  end

  def respond_unprocessable_entity(message)
    respond_to do |format|
      format.json { render json: message, status: :unprocessable_entity }
      format.html do
        flash[:notice] = message
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def vote_response(message)
    {
      resource_id:  @votable.id,
      type:         resource_type,
      rating:       @votable.vote_rating,
      message:      message
    }
  end

  def set_votable
    @votable = model_klass.find(params[:id])
  end
end
