class Question < ApplicationRecord
  belongs_to :user
  has_many   :answers, -> { order({ accepted: :desc, created_at: :asc }) },
             dependent: :destroy
  has_many   :attachments, as: :attachable, inverse_of: :attachable, dependent: :destroy
  has_many   :votes,       as: :votable,    inverse_of: :votable,    dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true,
                                reject_if: -> (attributes) { attributes['file'].blank? }

  validates :title, :body, presence: true

  def accepted_answer
    answers.accepted.find_by(question: self)
  end

  def answered?
    !accepted_answer.nil?
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
