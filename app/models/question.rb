class Question < ApplicationRecord
  include Votable

  belongs_to :user
  has_many   :answers, -> { order({ accepted: :desc, created_at: :asc }) },
             dependent: :destroy
  has_many   :attachments, as: :attachable, inverse_of: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true,
                                reject_if: -> (attributes) { attributes['file'].blank? }

  validates :title, :body, presence: true

  def accepted_answer
    answers.accepted.take
  end

  def answered?
    !accepted_answer.nil?
  end
end
