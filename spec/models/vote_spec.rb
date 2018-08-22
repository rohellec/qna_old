require 'rails_helper'

describe Vote do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :votable }

  # due to the bug in shoulda-matchers when testing uniqueness of fields with foreign-key contraint
  # should use this hack
  it do
    subject.user = create(:user)
    should validate_uniqueness_of(:user_id).scoped_to(:votable_type)
  end

  describe ":up_votes scope" do
    let!(:up_votes)  { create_pair(:question_up_vote) }
    let!(:down_vote) { create(:question_down_vote) }

    it "includes up-votes" do
      up_votes.each do |vote|
        expect(Vote.up_votes).to include vote
      end
    end

    it "doesn't includes down-votes" do
      expect(Vote.up_votes).not_to include down_vote
    end
  end
end
