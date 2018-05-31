class Question < ApplicationRecord
  belongs_to :user
  has_many   :answers, -> { order({ accepted: :desc, created_at: :asc }) },
             dependent: :destroy

  validates :title, :body, presence: true
end
