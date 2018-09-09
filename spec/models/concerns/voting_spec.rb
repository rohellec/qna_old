shared_examples "voting" do
  let(:votable)     { create(:question) }
  let(:voting_type) { described_class.model_name.name.underscore.to_sym }
  let(:voting)      { create(voting_type) }

  it { is_expected.to have_many(:votes).dependent(:nullify) }

  describe "#down_vote" do
    subject(:down_vote) { voting.down_vote votable }

    it { is_expected.to be_a Vote }

    it "returns vote with value equal to 'down'" do
      expect(down_vote.value).to eq Vote::DOWN
    end

    it "creates new vote for votable" do
      expect { voting.down_vote votable }.to change(votable.votes, :count).by(1)
    end

    it "decreases votable's vote rating" do
      expect { voting.down_vote votable }.to change(votable, :vote_rating).by(-1)
    end

    context "when called twice in a row" do
      before { voting.down_vote votable }

      it "doesn't change vote rating after the first time" do
        expect { voting.down_vote votable }.not_to change(votable.votes, :count)
      end
    end
  end

  describe "#up_vote" do
    subject(:up_vote) { voting.up_vote votable }

    it { is_expected.to be_a Vote }

    it "returns vote with value equal to 'up'" do
      expect(up_vote.value).to eq Vote::UP
    end

    it "creates new vote for votable" do
      expect { voting.up_vote votable }.to change(votable.votes, :count).by(1)
    end

    it "increases votable's vote rating" do
      expect { voting.up_vote votable }.to change(votable, :vote_rating).by(1)
    end

    context "when called twice in a row" do
      before { voting.up_vote votable }

      it "doesn't change vote rating after the first time" do
        expect { voting.up_vote votable }.not_to change(votable.votes, :count)
      end
    end
  end

  describe "#delete_vote" do
    context "when there is a voting's vote in db" do
      subject { voting.delete_vote(votable) }

      let!(:vote) { create(:up_vote, votable: votable, user: voting) }

      it { is_expected.to eq vote }

      it "deletes vote" do
        expect { voting.delete_vote(votable) }.to change(votable.votes, :count).by(-1)
      end
    end

    context "when there is no voting's vote in db" do
      subject { voting.delete_vote(votable) }

      it { is_expected.to be_nil }

      it "doesn't change number of votable's votes" do
        expect { voting.delete_vote(votable) }.not_to change(votable.votes, :count)
      end
    end
  end
end
