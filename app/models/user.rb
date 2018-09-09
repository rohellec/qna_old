class User < ApplicationRecord
  include Voting

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :questions, dependent: :destroy
  has_many :answers,   dependent: :destroy

  def author_of?(arg)
    id == arg.user_id
  end
end
