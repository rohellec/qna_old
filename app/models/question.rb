class Question < ApplicationRecord
  belongs_to :user
  has_many   :answers, -> { order({ accepted: :desc, created_at: :asc }) },
             dependent: :destroy

  validates :title, :body, presence: true

  def accepted_answer
    Answer.accepted.find_by(question_id: id)
  end

  def answered?
    !accepted_answer.nil?
  end
end
