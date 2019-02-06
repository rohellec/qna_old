class Answer < ApplicationRecord
  include Commentable
  include Votable

  scope :accepted, -> { where(accepted: true) }

  belongs_to :question
  belongs_to :user

  has_many :attachments, as: :attachable, inverse_of: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true,
                                reject_if: -> (attributes) { attributes['file'].blank? }

  validates :body, presence: true
  validate  :unique_acceptance

  def accept
    Answer.transaction do
      question.accepted_answer&.update!(accepted: false)
      update!(accepted: true)
      question.update!(answered: true)
    end
  end

  def remove_accept
    Answer.transaction do
      update!(accepted: false)
      question.update!(answered: false)
    end
  end

  protected

  def unique_acceptance
    return unless accepted?
    errors.add(:base, "Only one answer can be accepted") if question.accepted_answer.present?
  end
end
