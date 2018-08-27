class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :questions, dependent: :destroy
  has_many :answers,   dependent: :destroy
  has_many :votes,     dependent: :nullify

  def author_of?(arg)
    id == arg.user_id
  end

  def down_vote(votable)
    return if author_of?(votable) || votable.down_voted_by?(self)
    votable.votes.create(user: self, value: Vote::DOWN)
  end

  def up_vote(votable)
    return if author_of?(votable) || votable.up_voted_by?(self)
    votable.votes.create(user: self, value: Vote::UP)
  end

  def delete_vote_from(votable)
    vote = votable.votes.find_by(user: self)
    vote&.destroy
  end
end
