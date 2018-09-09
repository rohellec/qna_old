require "rails_helper"
require "models/concerns/votable_spec"

describe Question do
  let(:user) { create(:user) }
  let(:question) { create(:question) }
  let(:user_question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question) }

  it_behaves_like "votable"

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:answers).dependent(:destroy) }
  it { is_expected.to have_many(:attachments).dependent(:destroy) }

  it { is_expected.to accept_nested_attributes_for(:attachments) }

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :body  }

  describe "#answers" do
    let!(:answer_one) { create(:answer, question: question) }
    let!(:answer_two) { create(:answer, question: question) }

    context "when there is no accepted answer" do
      it "ordered by :created_at" do
        expect(question.answers).to eq [answer_one, answer_two]
      end
    end

    context "when there is an accepted answer" do
      it "ordered by :accepted" do
        answer_two.accept
        expect(question.answers).to eq [answer_two, answer_one]
      end
    end
  end

  describe "#accepted_answer" do
    it "returns accepted answer" do
      answer.accept
      expect(question.accepted_answer).to eq answer
    end

    it "returns nil if no answer were accepted" do
      expect(question.accepted_answer).to be_nil
    end
  end

  describe "#answered?" do
    it "returns true if there is an accepted answer" do
      answer.accept
      expect(question).to be_answered
    end

    it "returns false if there is no accepted answer" do
      expect(question).not_to be_answered
    end
  end
end
