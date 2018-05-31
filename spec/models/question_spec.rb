require 'rails_helper'

describe Question do
  let(:question) { create(:question) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:answers).dependent(:destroy) }

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
end
