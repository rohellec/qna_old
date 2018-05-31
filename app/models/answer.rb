class Answer < ApplicationRecord
  scope :accepted, -> { where(accepted: true) }

  belongs_to :question
  belongs_to :user

  validates :body, presence: true
end
