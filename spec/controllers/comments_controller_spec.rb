require "rails_helper"

describe CommentsController do
  let(:user) { create(:confirmed_user) }
  let(:commentable) { create(:question) }

  describe "POST #create" do
    let(:valid_attributes)   { attributes_for(:comment, commentable: commentable, user: user) }
    let(:invalid_attributes) { attributes_for(:invalid_comment) }

    context "when authenticated" do
      before { sign_in user }

      context "with valid attributes" do
        it "increases commentable comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: valid_attributes }
          end.to change(commentable.comments, :count).by(1)
        end

        it "increases user comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: valid_attributes }
          end.to change(user.comments, :count).by(1)
        end

        it "renders 'create.js' template" do
          post :create, params: { question_id: commentable, comment: valid_attributes }
          expect(response).to render_template "create.js"
        end
      end

      context "with invalid attributes" do
        it "doesn't increase commentable comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: invalid_attributes }
          end.not_to change(commentable.comments, :count)
        end

        it "increases user comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: invalid_attributes }
          end.not_to change(user.comments, :count)
        end

        it "renders 'error_messages.js' template" do
          post :create, params: { question_id: commentable, comment: invalid_attributes }
          expect(response).to render_template "error_messages.js"
        end
      end
    end

    context "when non-authenticated" do
      it "doesn't save new comment to db" do
        expect do
          post :create, params: { question_id: question, comment: valid_attributes }
        end
        .not_to change(Comment, :count)
      end

      it "redirects to sign in path" do
        post :create, params: { question_id: question, comment: valid_attributes }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update" do
    let(:user_comment)       { create(:comment, commentable: question, user: user) }
    let(:valid_attributes)   { attributes_for(:comment) }
    let(:invalid_attributes) { attributes_for(:invalid_comment) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        context "with valid attributes" do
          before do
            patch :update, params: { id: user_comment, comment: valid_attributes }, format: :js
          end

          it "assigns the requested comment" do
            expect(assigns(:comment)).to eq user_comment
          end

          it "changes answer body" do
            user_comment.reload
            expect(user_comment.body).to eq valid_attributes[:body]
          end

          it "renders 'update.js' template" do
            expect(response).to render_template "update.js"
          end
        end

        context "with invalid attributes" do
          before do
            patch :update, params: { id: user_comment, answer: invalid_attributes }, format: :js
          end

          it "doesn't update answer body" do
            user_comment.reload
            expect(user_comment).not_to eq valid_attributes[:body]
          end

          it "renders 'error_messages.js' template" do
            expect(response).to render_template "error_messages.js"
          end
        end
      end

      context "when is not author" do
        let!(:comment) { create(:comment) }

        it "redirects to fallback location root_url" do
          patch :update, params: { id: comment, comment: valid_attributes }
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      it "redirects to sign in path" do
        patch :update, params: { id: user_comment, comment: valid_attributes }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        let!(:user_comment)  { create(:comment, commentable: commentable, user: user) }

        it "assigns the requested answer" do
          delete :destroy, params: { id: user_comment }, format: :js
          expect(assigns(:comment)).to eq user_comment
        end

        it "deletes answer from db" do
          expect do
            delete :destroy, params: { id: user_comment }, format: :js
          end
          .to change(Comment, :count).by(-1)
        end

        it "renders 'destroy.js' template" do
          delete :destroy, params: { id: user_comment }, format: :js
          expect(response).to render_template "destroy.js"
        end
      end

      context "when is not author" do
        let!(:other_comment) { create(:comment, commentable: commentable) }

        it "doesn't delete answer from db" do
          expect do
            delete :destroy, params: { id: other_comment }
          end.not_to change(Comment, :count)
        end

        it "redirects to the fallback location root_url" do
          delete :destroy, params: { id: other_comment }
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      let!(:comment) { create(:comment) }

      it "doesn't delete answer from db" do
        expect do
          delete :destroy, params: { id: comment }
        end.not_to change(Comment, :count)
      end

      it "redirects to sign in path" do
        delete :destroy, params: { id: comment }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
