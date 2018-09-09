shared_examples "votable" do
  let(:user)         { create(:user) }
  let(:votable_type) { described_class.model_name.name.underscore.to_sym }
  let(:votable)      { create(votable_type) }

  it { is_expected.to have_many(:votes).dependent(:destroy) }

  describe "#down_voted_by?" do
    it "returns true if there is a down vote by user" do
      create(:down_vote, votable: votable, user: user)
      expect(votable).to be_down_voted_by(user)
    end

    it "returns false if there is no down vote by user" do
      expect(votable).not_to be_down_voted_by(user)
    end
  end

  describe "#up_voted_by?" do
    it "returns true if there is an up vote by user" do
      create(:up_vote, votable: votable, user: user)
      expect(votable).to be_up_voted_by(user)
    end

    it "returns false if there is no up vote by user" do
      expect(votable).not_to be_up_voted_by(user)
    end
  end

  describe "#vote_rating" do
    context "when there is no votes for this votable" do
      it "returns 0" do
        expect(votable.vote_rating).to be_zero
      end
    end

    context "when there are only down votes" do
      before { create_pair(:down_vote, votable: votable) }

      it "returns negative number" do
        expect(votable.vote_rating).to be_negative
      end
    end

    context "when there are only up votes" do
      before { create_pair(:up_vote, votable: votable) }

      it "returns negative number" do
        expect(votable.vote_rating).to be_positive
      end
    end
  end
end
