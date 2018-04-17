require 'rails_helper'

describe AnswersController do
  let(:user)     { create(:confirmed_user) }
  let(:question) { create(:question) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe "POST #create" do
    let(:valid_attributes)   { attributes_for(:answer, user: user) }
    let(:invalid_attributes) { attributes_for(:invalid_answer) }

    context "as authenticated user" do
      before { sign_in user }

      context "with valid attributes" do
        it "creates new answer for question" do
          expect do
            post :create, params: { question_id: question, answer: valid_attributes }
          end
          .to change(question.answers, :count).by(1)
        end

        it "creates new answer for user" do
          expect do
            post :create, params: { question_id: question, answer: valid_attributes }
          end
          .to change(user.answers, :count).by(1)
        end

        it "redirects to question's 'show' action" do
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

        it "re-renders 'questions/show' view" do
          post :create, params: { question_id: question, answer: invalid_attributes }
          expect(response).to render_template("questions/show")
        end
      end
    end

    context "as non-authenticated user" do
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

  describe "DELETE #destroy" do
    context "as authenticated user" do
      before { sign_in user }

      context "as answer's author" do
        let!(:user_answer)  { create(:answer, question: question, user: user) }

        it "deletes answer from db" do
          expect do
            delete :destroy, params: { id: user_answer }
          end
          .to change(Answer, :count).by(-1)
        end

        it "redirects to question_path" do
          delete :destroy, params: { id: user_answer }
          expect(response).to redirect_to question
        end
      end

      context "other user's answer" do
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

    context "as non-authenticated user" do
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
