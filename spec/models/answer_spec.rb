require 'rails_helper'

describe Answer do
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
end
