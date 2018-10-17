require 'rails_helper'

describe Vote do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :votable }

  # it seems that shoulda-matchers doesn't work for validating
  # uniquenes within the scope of polymorphic foreign_key
  describe "validation of user_id uniqueness for votable" do
    subject(:vote) { build(:down_vote, user: user, votable: votable) }

    let(:user)    { create(:user) }
    let(:votable) { create(:question) }

    before { create(:up_vote, user: user, votable: votable) }

    it "doesn't save vote in db if user_id isn't unique" do
      expect { vote.save }.not_to change(described_class, :count)
    end

    it "adds error message to invalid vote" do
      vote.save
      expect(vote.errors[:user_id]).to include I18n.t("errors.messages.taken")
    end
  end

  describe "validation :user_vote_ability" do
    subject(:vote) { build(:up_vote, votable: votable, user: user) }

    let(:user)    { create(:user) }
    let(:votable) { create(:question, user: user) }

    it "doesn't save vote in db if it's invalid" do
      expect { vote.save }.not_to change(described_class, :count)
    end

    it "adds error message to invalid vote" do
      vote.valid?
      expect(vote.errors.full_messages).to include "User can't vote on his own question"
    end
  end
end
