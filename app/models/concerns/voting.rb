module Voting
  extend ActiveSupport::Concern

  included do
    has_many :votes, dependent: :nullify
  end

  def down_vote(votable)
    votable.votes.create(user: self, value: Vote::DOWN)
  end

  def up_vote(votable)
    votable.votes.create(user: self, value: Vote::UP)
  end

  def delete_vote(votable)
    vote = votable.votes.find_by(user: self)
    vote&.destroy
  end
end
