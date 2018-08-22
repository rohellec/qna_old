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

  describe "#up_vote" do
    context "when author of question" do
      let(:up_vote_question) { user.up_vote user_question }

      it "returns nil" do
        expect(up_vote_question).to be_nil
      end
    end

    context "when is not author of question" do
      let(:up_vote_question) { user.up_vote question }

      it "returns newly created vote" do
        expect(up_vote_question).to be_a Vote
      end

      it "creates new vote for question" do
        expect { user.up_vote question }.to change(question.votes, :count).by 1
      end

      it "creates vote with value eq to 'up'" do
        expect(up_vote_question.value).to eq "up"
      end

      it "doesn't up-vote already upvoted resource" do
        user.up_vote question
        expect { user.up_vote question }.not_to change(question.votes, :count)
      end
    end
  end

  describe "#delete_vote_from" do
    context "when there is a user's vote in db" do
      let!(:vote) { create(:up_vote, votable: question, user: user) }

      it "deletes vote" do
        expect { user.delete_vote_from question }.to change(question.votes, :count).by -1
      end

      it "returns deleted vote" do
        deleted_vote = user.delete_vote_from question
        expect(deleted_vote).to eq vote
      end
    end

    context "when there is no user's vote in db" do
      let(:delete_vote_from_question) { user.delete_vote_from question }

      it "doen't change number of votes for question" do
        expect { user.delete_vote_from question }.not_to change(question.votes, :count)
      end

      it "returns nil" do
        expect(delete_vote_from_question).to be_nil
      end
    end
  end
end
