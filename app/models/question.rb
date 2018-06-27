class Question < ApplicationRecord
  belongs_to :user
  has_many   :answers, -> { order({ accepted: :desc, created_at: :asc }) },
             dependent: :destroy
  has_many   :attachments, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true

  validates :title, :body, presence: true

  def accepted_answer
    answers.accepted.find_by(question_id: id)
  end

  def answered?
    !accepted_answer.nil?
  end
end
