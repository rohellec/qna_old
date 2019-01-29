require "rails_helper"

describe CommentsController do
  let(:user)        { create(:confirmed_user) }
  let(:commentable) { create(:question) }

  describe "POST #create" do
    let(:valid_attributes)   { attributes_for(:comment) }
    let(:invalid_attributes) { attributes_for(:invalid_comment) }

    context "when authenticated" do
      before { sign_in user }

      # is it necessary to write specs for answers also? Here is only question_id
      context "with valid attributes" do
        it "increases commentable comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: valid_attributes,
                                    commentable: "questions" },
                          format: :js
          end.to change(commentable.comments, :count).by(1)
        end

        it "increases user comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: valid_attributes,
                                    commentable: "questions" },
                          format: :js
          end.to change(user.comments, :count).by(1)
        end

        describe "request" do
          before do
            post :create, params: { question_id: commentable, comment: valid_attributes,
                                    commentable: "questions" },
                          format: :js
          end

          it "assigns the corresponded commentable" do
            expect(assigns(:commentable)).to eq commentable
          end

          it "response has :success http status" do
            expect(response).to have_http_status(:success)
          end

          it "response has 'application/json' content type" do
            expect(response.content_type).to eq "application/json"
          end

          it "response body contains comment data" do
            expect(response.body).to match "\"body\":\"#{valid_attributes[:body]}\""
          end

          it "response body contains message" do
            expect(response.body).to match(
              "\"message\":\"#{I18n.translate("comments.create.message")}\""
            )
          end
        end
      end

      context "with invalid attributes" do
        it "doesn't increase commentable comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: invalid_attributes,
                                    commentable: "questions" },
                          format: :js
          end.not_to change(commentable.comments, :count)
        end

        it "increases user comments count" do
          expect do
            post :create, params: { question_id: commentable, comment: invalid_attributes,
                                    commentable: "questions" },
                          format: :js
          end.not_to change(user.comments, :count)
        end

        describe "request" do
          before do
            post :create, params: { question_id: commentable, comment: invalid_attributes,
                                    commentable: "questions" },
                          format: :js
          end

          it "assigns the corresponded commentable" do
            expect(assigns(:commentable)).to eq commentable
          end

          it "response has :forbidden http status" do
            expect(response).to have_http_status(:forbidden)
          end

          it "response has 'application/json' content type" do
            expect(response.content_type).to eq "application/json"
          end

          it "response body contains error messages" do
            expect(response.body).to match "can't be blank"
          end
        end
      end
    end

    context "when non-authenticated" do
      it "doesn't save new comment to db" do
        expect do
          post :create, params: { question_id: commentable, comment: valid_attributes }
        end
        .not_to change(Comment, :count)
      end

      it "redirects to sign in path" do
        post :create, params: { question_id: commentable, comment: valid_attributes }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update" do
    let(:user_comment)       { create(:comment, commentable: commentable, user: user) }
    let(:valid_attributes)   { attributes_for(:comment, commentable: commentable, user: user) }
    let(:invalid_attributes) { attributes_for(:invalid_comment, commentable: commentable, user: user) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        context "with valid attributes" do
          before do
            patch :update, params: { id: user_comment, comment: valid_attributes },
                           format: :js
          end

          it "assigns the requested comment" do
            expect(assigns(:comment)).to eq user_comment
          end

          it "changes answer body" do
            user_comment.reload
            expect(user_comment.body).to eq valid_attributes[:body]
          end

          describe "response" do
            it "has :success http status" do
              expect(response).to have_http_status(:success)
            end

            it "has 'application/json' content type" do
              expect(response.content_type).to eq "application/json"
            end

            it "body contains new comment text" do
              expect(response.body).to match "\"body\":\"#{valid_attributes[:body]}\""
            end

            it "body contains message" do
              expect(response.body).to match(
                "\"message\":\"#{I18n.translate("comments.update.message")}\""
              )
            end
          end
        end

        context "with invalid attributes" do
          before do
            patch :update, params: { id: user_comment, comment: invalid_attributes },
                           format: :js
          end

          it "assigns the requested comment" do
            expect(assigns(:comment)).to eq user_comment
          end

          it "doesn't update answer body" do
            user_comment.reload
            expect(user_comment).not_to eq valid_attributes[:body]
          end

          describe "response" do
            it "has :forbidden http status" do
              expect(response).to have_http_status(:forbidden)
            end

            it "has 'application/json' content type" do
              expect(response.content_type).to eq "application/json"
            end

            it "body contains error messages" do
              expect(response.body).to match "can't be blank"
            end
          end
        end
      end

      context "when is not author" do
        let(:comment) { create(:comment, commentable: commentable) }

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

        it "deletes answer from db" do
          expect do
            delete :destroy, params: { id: user_comment, commentable: "questions" },
                             format: :js
          end
          .to change(Comment, :count).by(-1)
        end

        describe "request" do
          before do
            delete :destroy, params: { id: user_comment, commentable: "questions" },
                             format: :js
          end

          it "assigns the requested comment" do
            expect(assigns(:comment)).to eq user_comment
          end

          it "response has :success http status" do
            expect(response).to have_http_status(:success)
          end

          it "response has 'application/json' content type" do
            expect(response.content_type).to eq "application/json"
          end

          it "response body contains comment data" do
            expect(response.body).to match "\"body\":\"#{user_comment.body}\""
          end

          it "response body contains message" do
            expect(response.body).to match(
              "\"message\":\"#{I18n.translate("comments.destroy.message")}\""
            )
          end
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
      let!(:comment) { create(:comment, commentable: commentable) }

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
