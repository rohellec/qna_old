class Vote < ApplicationRecord
  UP   =  1
  DOWN = -1

  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :user_id, uniqueness: { scope: :votable_type }
end
