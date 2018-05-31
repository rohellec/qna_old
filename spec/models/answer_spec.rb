require 'rails_helper'

describe Answer do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :question }
  it { is_expected.to validate_presence_of :body }

  describe ":accepted scope" do
    let!(:accepted_answers) { create_pair(:accepted_answer) }
    let!(:answer) { create(:answer) }

    it "includes accepted answers" do
      accepted_answers.each do |answer|
        expect(Answer.accepted).to include answer
      end
    end

    it "doesn't include non-accepted answers" do
      expect(Answer.accepted).not_to include answer
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
end
