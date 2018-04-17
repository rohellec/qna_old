require 'rails_helper'

describe User do
  it { is_expected.to have_many(:questions) }
  it { is_expected.to have_many(:answers) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }

  describe "#author_of?(arg)" do
    let(:user) { create(:user) }
    let(:user_question)  { create(:question, user: user) }
    let(:other_question) { create(:question) }

    it "returns true for user's question" do
      expect(user).to be_author_of(user_question)
    end

    it "returns false for other user's question" do
      expect(user).not_to be_author_of(other_question)
    end
  end
end
