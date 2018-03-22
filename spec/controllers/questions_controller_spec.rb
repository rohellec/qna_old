require 'rails_helper'

describe QuestionsController do
  describe "GET #index" do
    let(:questions) { FactoryBot.create_pair(:question) }

    before { get :index }

    it "populates an array of all created questions" do
      expect(assigns(:questions)).to match_array(questions)
    end

    it "renders 'index' view" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    let(:question) { FactoryBot.create(:question) }
    let(:answers)  { FactoryBot.create_pair(:answer, question: question) }

    before { get :show, params: { id: question } }

    it "sets requested question" do
      expect(assigns(:question)).to eq(question)
    end

    it "populates an array of answers for current question" do
      expect(assigns(:answers)).to eq(answers)
    end

    it "renders 'show' view" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before { get :new }

    it "builds new question" do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it "renders 'new' view" do
      expect(response).to render_template :new
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) { FactoryBot.attributes_for(:question) }

      it "saves the new question to db" do
        expect do
          post :create, params: { question: valid_attributes }
        end.to change(Question, :count).by(1)
      end

      it "redirects to 'show' view" do
        post :create, params: { question: valid_attributes }
        expect(response).to redirect_to question_path(assigns(:question))
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryBot.attributes_for(:invalid_question) }

      it "doesn't save the new question to db" do
        expect do
          post :create, params: { question: invalid_attributes }
        end.not_to change(Question, :count)
      end

      it "re-renders 'new' view" do
        post :create, params: { question: invalid_attributes }
        expect(response).to render_template :new
      end
    end
  end
end
