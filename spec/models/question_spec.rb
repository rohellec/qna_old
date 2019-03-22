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
  it { is_expected.to have_many(:comments).dependent(:destroy) }

  it { is_expected.to accept_nested_attributes_for(:attachments) }

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :body  }

  describe "validation :question_answered" do
    before { question.update(answered: true) }

    it "makes question invalid if there're no accepted answers" do
      expect(question).to be_invalid
    end

    it "adds error message to invalid question" do
      error_message = "Question must have an accepted answer before it can be marked as answered"
      expect(question.errors.full_messages).to include(error_message)
    end
  end

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

  describe "#answers_by_rating" do
    before do
      (1..5).each { |count| create(:answer_with_votes, votes_count: count, question: question) }
    end

    context "when there is no accepted answer" do
      it "ordered by :vote_rating" do
        answers_by_rating = question.answers_by_rating
        answers_by_rating.each_with_index do |answer, i|
          unless answer.equal? answers_by_rating.last
            expect(answer.vote_rating).to be > answers_by_rating[i + 1].vote_rating
          end
        end
      end

      it "ordered by :created_at when :vote_rating is equal" do
        (1..5).each { |count| create(:answer_with_votes, votes_count: count, question: question) }
        answers_by_rating = question.answers_by_rating
        (0..9).step(2) do |i|
          expect(answers_by_rating[i].created_at).to be < answers_by_rating[i + 1].created_at
        end
      end
    end

    context "when there is an accepted answer" do
      before { answer.accept }

      it "ordered by :accepted" do
        expect(question.answers_by_rating.first).to eq answer
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
