require 'rails_helper'

describe Vote do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :votable }
  it { is_expected.to validate_inclusion_of(:value).in_array [-1, 1] }

  describe "validation :unique_user" do
    let(:user) { create(:user) }
    let(:question) { create(:question) }
    let!(:created_up_vote) { create(:vote, user: user, question: question) }
    let(:up_vote) { build(:vote, user: user, question: question) }

    it "doesn't save vote to database if invalid" do
      expect { up_vote.save }.not_to change(question.votes, :count)
    end

    it "adds error message to invalid vote" do
      up_vote.save
      expect(up_vote.errors.full_messages).to
        include "Only one vote for question can be created by user"
    end
  end
end
