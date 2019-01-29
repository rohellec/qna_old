require "rails_helper"
require "models/concerns/votable_spec"

describe Answer do
  let(:user)     { create(:user) }
  let(:question) { create(:question, user: user) }

  it_behaves_like "votable"

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :question }
  it { is_expected.to have_many(:comments).dependent(:destroy) }

  it { is_expected.to validate_presence_of :body }

  describe ":accepted scope" do
    let!(:accepted_answers) { create_pair(:accepted_answer) }
    let!(:answer) { create(:answer) }

    it "includes accepted answers" do
      accepted_answers.each do |answer|
        expect(described_class.accepted).to include answer
      end
    end

    it "doesn't include non-accepted answers" do
      expect(described_class.accepted).not_to include answer
    end
  end

  describe "validation :unique_acceptance" do
    let!(:accepted_answer) { create(:accepted_answer, question: question) }
    let!(:answer) { build(:accepted_answer, question: question) }

    it "doesn't save answer to database if invalid" do
      expect { answer.save }.not_to change(question.answers, :count)
    end

    it "adds error message to invalid answer" do
      answer.save
      expect(answer.errors.full_messages).to include "Only one answer can be accepted"
    end
  end

  describe "#accept" do
    let!(:answer)       { create(:answer, question: question) }
    let!(:other_answer) { create(:answer, question: question) }

    before { answer.accept }

    it "sets #accepted? for chosen answer to true" do
      expect(answer).to be_accepted
    end

    it "makes selected answer first in the default scope" do
      expect(answer).to eq question.answers.first
    end

    it "adds answer to accepted scope" do
      expect(described_class.accepted).to include(answer)
    end

    context "when accepting another answer" do
      before { other_answer.accept }

      it "sets #accepted? for previous answer to false" do
        answer.reload
        expect(answer).not_to be_accepted
      end

      it "sets #accepted? for newly answer to true" do
        expect(other_answer).to be_accepted
      end

      it "makes new answer first in the default scope" do
        expect(other_answer).to eq question.answers.first
      end
    end
  end

  describe "#remove_accept" do
    let!(:answer) { create(:answer, question: question) }
    let!(:accepted_answer) { create(:accepted_answer, question: question) }

    before { accepted_answer.remove_accept }

    it "sets #accepted? for answer to false" do
      expect(accepted_answer).not_to be_accepted
    end

    it "applies default scope ordering for answers" do
      expect(answer).to eq question.answers.first
    end
  end
end
