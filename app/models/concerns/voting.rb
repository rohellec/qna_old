module Voting
  extend ActiveSupport::Concern

  included do
    has_many :votes, dependent: :nullify
  end

  def down_vote(votable)
    votes.create(votable: votable, value: Vote::DOWN)
  end

  def up_vote(votable)
    votes.create(votable: votable, value: Vote::UP)
  end

  def delete_vote(votable)
    vote = votes.find_by(votable: votable)
    vote&.destroy
  end
end
