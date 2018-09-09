class Vote < ApplicationRecord
  UP   =  1
  DOWN = -1

  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :user_id, uniqueness: { scope: :votable_type }
  validate  :user_vote_ability

  private

  def user_vote_ability
    errors.add(:user, "can't vote on his own question") if user == votable.user
  end
end
