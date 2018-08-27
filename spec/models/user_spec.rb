require 'rails_helper'

describe User do
  let(:user) { create(:user) }
  let(:question) { create(:question) }
  let(:user_question)  { create(:question, user: user) }

  it { is_expected.to have_many(:questions).dependent(:destroy) }
  it { is_expected.to have_many(:answers).dependent(:destroy) }
  it { is_expected.to have_many(:votes).dependent(:nullify) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }

  describe "#author_of?(arg)" do
    it "returns true for user's question" do
      expect(user).to be_author_of(user_question)
    end

    it "returns false for other user's question" do
      expect(user).not_to be_author_of(question)
    end
  end

  describe "#down_vote" do
    context "when author of question" do
      subject { user.down_vote user_question }

      it { is_expected.to be_nil }

      it "doesn't decrease question's vote rating" do
        expect { user.down_vote user_question }.not_to change(question, :vote_rating)
      end
    end

    context "when is not author of question" do
      subject(:down_vote) { user.down_vote question }

      it { is_expected.to be_a Vote }

      it "returns vote with value equal to 'down'" do
        expect(down_vote.value).to eq Vote::DOWN
      end

      it "creates new vote for question" do
        expect { user.down_vote question }.to change(question.votes, :count).by(1)
      end

      it "decreases question's vote rating" do
        expect { user.down_vote question }.to change(question, :vote_rating).by(-1)
      end

      context "when called twice in a row" do
        before { user.down_vote question }

        it "doesn't change vote rating after the first time" do
          expect { user.down_vote question }.not_to change(question.votes, :count)
        end
      end
    end
  end

  describe "#up_vote" do
    context "when author of question" do
      subject { user.up_vote user_question }

      it { is_expected.to be_nil }

      it "doesn't increase question's vote rating" do
        expect { user.up_vote user_question }.not_to change(question, :vote_rating)
      end
    end

    context "when is not author of question" do
      subject(:up_vote) { user.up_vote question }

      it { is_expected.to be_a Vote }

      it "returns vote with value equal to 'up'" do
        expect(up_vote.value).to eq Vote::UP
      end

      it "creates new vote for question" do
        expect { user.up_vote question }.to change(question.votes, :count).by(1)
      end

      it "increases question's vote rating" do
        expect { user.up_vote question }.to change(question, :vote_rating).by(1)
      end

      context "when called twice in a row" do
        before { user.up_vote question }

        it "doesn't change vote rating after the first time" do
          expect { user.up_vote question }.not_to change(question.votes, :count)
        end
      end
    end
  end

  describe "#delete_vote_from" do
    context "when there is a user's vote in db" do
      subject { user.delete_vote_from question }

      let!(:vote) { create(:up_vote, votable: question, user: user) }

      it { is_expected.to eq vote }

      it "deletes vote" do
        expect { user.delete_vote_from question }.to change(question.votes, :count).by(-1)
      end
    end

    context "when there is no user's vote in db" do
      subject { user.delete_vote_from question }

      it { is_expected.to be_nil }

      it "doesn't change number of question's votes" do
        expect { user.delete_vote_from question }.not_to change(question.votes, :count)
      end
    end
  end
end
