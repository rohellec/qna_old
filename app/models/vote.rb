class Vote < ApplicationRecord
  scope :up_votes, -> { where(value: VALUES[:up]) }

  VALUES = {
    up:   "up",
    down: "down"
  }.freeze

  enum value: { up: 1, down: -1 }

  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :user_id, uniqueness: { scope: :votable_type }
end
