class Answer < ApplicationRecord
  scope :accepted, -> { where(accepted: true) }

  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validate  :unique_acceptance

  def unique_acceptance
    return unless accepted?
    accepted_answer = Answer.accepted.where(question: question)
    accepted_answer = accepted_answer.where('id != ?', id) if persisted?
    errors.add(:base, "Only one answer can be accepted") if accepted_answer.exists?
  end
end
