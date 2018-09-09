require 'rails_helper'

describe Vote do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :votable }

  # due to the bug in shoulda-matchers when testing uniqueness of fields with foreign-key contraint
  # should use this hack
  it do
    subject.user = create(:user)
    subject.votable = create(:question)
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:votable_type)
  end

  describe "validation :user_vote_ability" do
    let!(:user)    { create(:user) }
    let!(:votable) { create(:question, user: user) }
    let!(:vote)    { build(:up_vote, votable: votable, user: user) }

    it "doesn't save vote in db if it's invalid" do
      expect { vote.save }.not_to change(votable.votes, :count)
    end

    it "adds error message to invalid vote" do
      vote.valid?
      expect(vote.errors.full_messages).to include "User can't vote on his own question"
    end
  end
end
