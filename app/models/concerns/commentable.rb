module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, -> { order(created_at: :asc) },
             as: :commentable, inverse_of: :commentable, dependent: :destroy
  end
end
