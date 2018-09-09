require "rails_helper"
require "models/concerns/voting_spec"

describe User do
  let(:user) { create(:user) }
  let(:question) { create(:question) }
  let(:user_question)  { create(:question, user: user) }

  it_behaves_like "voting"

  it { is_expected.to have_many(:questions).dependent(:destroy) }
  it { is_expected.to have_many(:answers).dependent(:destroy) }

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
end
