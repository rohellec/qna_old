class Question < ApplicationRecord
  include Commentable
  include Votable

  belongs_to :user
  has_many   :answers, -> { order({ accepted: :desc, created_at: :asc }) },
             dependent: :destroy
  has_many   :attachments, as: :attachable, inverse_of: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true,
                                reject_if: -> (attributes) { attributes['file'].blank? }

  validates :title, :body, presence: true
  validate  :question_answered

  def accepted_answer
    answers.accepted.take
  end

  # stable sort of answers by vote rating
  def answers_by_rating
    n = 0
    answers.sort_by do |answer|
      n += 1
      sorting_criteria = answer.accepted ? 0 : 1
      [sorting_criteria, -answer.vote_rating, n]
    end
  end

  private

  def question_answered
    return unless answered?
    error_message = "Question must have an accepted answer before it can be marked as answered"
    errors.add(:base, error_message) if accepted_answer.nil?
  end
end
