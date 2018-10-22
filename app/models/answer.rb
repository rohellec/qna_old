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
      question.accepted_answer&.remove_accept
      update(accepted: true)
    end
  end

  def remove_accept
    update(accepted: false)
  end

  protected

  def unique_acceptance
    return unless accepted?
    errors.add(:base, "Only one answer can be accepted") if question.answered?
  end
end
