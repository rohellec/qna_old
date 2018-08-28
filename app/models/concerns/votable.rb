module Votable
  extend ActiveSupport::Concern

  included do
    has_many   :votes, as: :votable, inverse_of: :votable, dependent: :destroy
  end

  def up_voted_by?(user)
    vote = votes.find_by(user: user)
    vote&.value == Vote::UP
  end

  def down_voted_by?(user)
    vote = votes.find_by(user: user)
    vote&.value == Vote::DOWN
  end

  def vote_rating
    votes.sum(:value)
  end
end
