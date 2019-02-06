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

  private

  def question_answered
    return unless answered?
    error_message = "Question must have an accepted answer before it can be marked as answered"
    errors.add(:base, error_message) if accepted_answer.nil?
  end
end
