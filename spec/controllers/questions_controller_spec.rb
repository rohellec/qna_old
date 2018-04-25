require 'rails_helper'

describe QuestionsController do
  let(:user) { create(:confirmed_user) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe "GET #index" do
    let(:questions) { create_pair(:question) }

    before { get :index }

    it "populates an array of all created questions" do
      expect(assigns(:questions)).to match_array(questions)
    end

    it "renders 'index' view" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    let(:question) { create(:question) }
    let(:answers)  { create_pair(:answer, question: question) }

    before { get :show, params: { id: question } }

    it "sets requested question" do
      expect(assigns(:question)).to eq question
    end

    it "populates an array of answers for current question" do
      expect(assigns(:answers)).to match_array answers
    end

    it "builds new answer" do
      expect(assigns(:answer)).to be_a_new Answer
    end

    it "renders 'show' view" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    context "when authenticated" do
      before do
        sign_in user
        get :new
      end

      it "builds new question" do
        expect(assigns(:question)).to be_a_new(Question)
      end

      it "renders 'new' view" do
        expect(response).to render_template :new
      end
    end

    context "when non-authenticated" do
      before { get :new }

      it "redirects to sign in path" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes)   { attributes_for(:question, user: user) }
    let(:invalid_attributes) { attributes_for(:invalid_question) }

    context "when authenticated" do
      before { sign_in user }

      context "with valid attributes" do
        it "creates new question for user" do
          expect do
            post :create, params: { question: valid_attributes }
          end.to change(user.questions, :count).by(1)
        end

        it "redirects to question_path" do
          post :create, params: { question: valid_attributes }
          expect(response).to redirect_to question_path(assigns(:question))
        end
      end

      context "with invalid attributes" do
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

    context "when non-authenticated" do
      before { post :create, params: { question: valid_attributes } }

      it "redirects to sign in path" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update" do
    let(:question) { create(:question) }
    let(:new_attributes) { attributes_for(:question) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        let(:user_question) { create(:question, user: user) }

        context "with valid attributes" do
          before do
            patch :update, params: { id: user_question, question: new_attributes }, format: :js
          end

          it "updates question attributes" do
            user_question.reload
            expect(user_question.title).to eq new_attributes[:title]
            expect(user_question.body).to  eq new_attributes[:body]
          end

          it "redirects to question_path" do
            expect(response).to redirect_to user_question
          end
        end

        context "with invalid attributes" do
          let(:invalid_attributes) { attributes_for(:invalid_question) }

          before do
            patch :update, params: { id: user_question, question: invalid_attributes }, format: :js
          end

          it "doesn't update question attributes" do
            user_question.reload
            expect(user_question.title).not_to eq new_attributes[:title]
            expect(user_question.body).not_to  eq new_attributes[:body]
          end

          it "renders 'error_messages' template" do
            expect(response).to render_template(:error_messages)
          end
        end
      end

      context "when is not author" do
        before do
          patch :update, params: { id: question, question: new_attributes }, format: :js
        end

        it "redirects to fallback location root_url" do
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      before do
        patch :update, params: { id: question, question: new_attributes }
      end

      it "redirects to sign in path" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user_question) { create(:question, user: user) }
    let!(:other_user_question) { create(:question) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        it "deletes question from db" do
          expect do
            delete :destroy, params: { id: user_question }
          end.to change(Question, :count).by(-1)
        end

        context "with HTML request" do
          it "redirects to 'index'" do
            delete :destroy, params: { id: user_question }
            expect(response).to redirect_to questions_path
          end
        end

        context "with AJAX request" do
          it "redirects to 'index'" do
            delete :destroy, params: { id: user_question }, format: :js
            expect(response).to render_template("destroy")
          end
        end
      end

      context "when is not author" do
        it "doesn't delete question from db" do
          expect do
            delete :destroy, params: { id: other_user_question }
          end.not_to change(Question, :count)
        end

        it "redirects to the fallback location root_url" do
          delete :destroy, params: { id: other_user_question }
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      it "doesn't delete question from db" do
        expect do
          delete :destroy, params: { id: user_question }
        end.not_to change(Question, :count)
      end

      it "redirects to sign in path" do
        delete :destroy, params: { id: user_question }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
