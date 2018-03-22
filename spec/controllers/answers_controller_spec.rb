require 'rails_helper'

describe AnswersController do
  describe "GET #new" do
    let(:question) { FactoryBot.create(:question) }

    before { get :new, params: { question_id: question } }

    it "builds new answer" do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it "renders 'new' view" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:question) { FactoryBot.create(:question) }
    let(:valid_attributes)   { FactoryBot.attributes_for(:answer) }
    let(:invalid_attributes) { FactoryBot.attributes_for(:invalid_answer) }

    context "with valid attributes" do
      it "saves new answer to db" do
        expect do
          post :create, params: { question_id: question, answer: valid_attributes }
        end
        .to change(Answer, :count).by(1)
      end

      it "redirects to 'index' view" do
        post :create, params: { question_id: question, answer: valid_attributes }
        expect(response).to redirect_to question
      end
    end

    context "with invalid attributes" do
      it "doesn't save new answer to db" do
        expect do
          post :create, params: { question_id: question, answer: invalid_attributes }
        end
        .not_to change(Answer, :count)
      end

      it "re-renders 'new' view" do
        post :create, params: { question_id: question, answer: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end
end
