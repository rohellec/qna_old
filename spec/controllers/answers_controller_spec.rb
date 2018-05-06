require 'rails_helper'

describe AnswersController do
  let(:user)     { create(:confirmed_user) }
  let(:question) { create(:question) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe "POST #create" do
    let(:valid_attributes)   { attributes_for(:answer, user: user) }
    let(:invalid_attributes) { attributes_for(:invalid_answer) }

    context "when authenticated" do
      before { sign_in user }

      context "with valid attributes" do
        it "creates new answer for question" do
          expect do
            post :create, params: { question_id: question, answer: valid_attributes }, format: :js
          end
          .to change(question.answers, :count).by(1)
        end

        it "creates new answer for user" do
          expect do
            post :create, params: { question_id: question, answer: valid_attributes }, format: :js
          end
          .to change(user.answers, :count).by(1)
        end

        it "renders 'create.js' template" do
          post :create, params: { question_id: question, answer: valid_attributes }, format: :js
          expect(response).to render_template "create"
        end
      end

      context "with invalid attributes" do
        it "doesn't save new answer to db" do
          expect do
            post :create, params: { question_id: question, answer: invalid_attributes }, format: :js
          end
          .not_to change(Answer, :count)
        end

        it "renders 'error_messages.js' template" do
          post :create, params: { question_id: question, answer: invalid_attributes }, format: :js
          expect(response).to render_template "error_messages"
        end
      end
    end

    context "when non-authenticated" do
      it "doesn't save new answer to db" do
        expect do
          post :create, params: { question_id: question, answer: valid_attributes }
        end
        .not_to change(Answer, :count)
      end

      it "redirects to sign in path" do
        post :create, params: { question_id: question, answer: valid_attributes }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update" do
    let!(:user_answer) { create(:answer, question: question, user: user) }
    let(:valid_attributes)   { attributes_for(:answer) }
    let(:invalid_attributes) { attributes_for(:invalid_answer) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        context "with valid attributes" do
          before do
            patch :update, params: { id: user_answer, answer: valid_attributes }, format: :js
          end

          it "assigns the requested answer" do
            expect(assigns(:answer)).to eq user_answer
          end

          it "changes answer body" do
            user_answer.reload
            expect(user_answer.body).to eq valid_attributes[:body]
          end

          it "renders 'update.js' template" do
            expect(response).to render_template :update
          end
        end

        context "with invalid attributes" do
          before do
            patch :update, params: { id: user_answer, answer: invalid_attributes }, format: :js
          end

          it "doesn't update answer body" do
            user_answer.reload
            expect(user_answer).not_to eq valid_attributes[:body]
          end

          it "renders 'error_messages' template" do
            expect(response).to render_template :error_messages
          end
        end
      end

      context "when is not author" do
        let!(:answer) { create(:answer) }

        it "redirects to fallback location root_url" do
          patch :update, params: { id: answer, answer: valid_attributes }
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      it "redirects to sign in path" do
        patch :update, params: { id: user_answer, answer: valid_attributes }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        let!(:user_answer)  { create(:answer, question: question, user: user) }

        it "deletes answer from db" do
          expect do
            delete :destroy, params: { id: user_answer }, format: :js
          end
          .to change(Answer, :count).by(-1)
        end

        it "redirects to question_path" do
          delete :destroy, params: { id: user_answer }, format: :js
          expect(response).to render_template :destroy
        end
      end

      context "when is not author" do
        let!(:other_answer) { create(:answer, question: question) }

        it "doesn't delete answer from db" do
          expect do
            delete :destroy, params: { id: other_answer }
          end.not_to change(Answer, :count)
        end

        it "redirects to the fallback location root_url" do
          delete :destroy, params: { id: other_answer }
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      let!(:answer) { create(:answer) }

      it "doesn't delete answer from db" do
        expect do
          delete :destroy, params: { id: answer }
        end.not_to change(Answer, :count)
      end

      it "redirects to sign in path" do
        delete :destroy, params: { id: answer }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
