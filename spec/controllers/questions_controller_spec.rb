require "rails_helper"
require "controllers/concerns/voted"

describe QuestionsController do
  let(:user) { create(:confirmed_user) }

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  it_behaves_like "voted"

  describe "GET #new" do
    context "when authenticated" do
      before do
        sign_in user
        get :new
      end

      it "renders 'new' view" do
        expect(response).to render_template :new
      end
    end

    context "when non-authenticated" do
      it "redirects to sign in path" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #edit" do
    let(:user_question)  { create(:question, user: user) }
    let(:other_question) { create(:question) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        before { get :edit, params: { id: user_question } }

        it "renders 'edit' template" do
          expect(response).to render_template :edit
        end
      end

      context "when is not author" do
        it "redirects to fallback location root_url" do
          get :edit, params: { id: other_question }
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      it "redirects to sign in path" do
        get :edit, params: { id: other_question }
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
      end

      context "with nested attachments attributes" do
        let(:attributes) { attributes_for(:question_with_attachment, user: user) }

        it "creates new question attachment" do
          expect do
            post :create, params: { question: attributes }
          end.to change(Attachment, :count).by(1)
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
    let(:valid_attributes)   { attributes_for(:question) }
    let(:invalid_attributes) { attributes_for(:invalid_question) }

    context "when authenticated" do
      before { sign_in user }

      context "when author" do
        let(:user_question) { create(:question, user: user) }

        context "with valid attributes using :html format" do
          before do
            patch :update, params: { id: user_question, question: valid_attributes }
          end

          it "updates question attributes" do
            user_question.reload
            expect(user_question.title).to eq valid_attributes[:title]
            expect(user_question.body).to  eq valid_attributes[:body]
          end
        end

        context "with valid attributes using :json format" do
          before do
            patch :update, params: { id: user_question, question: valid_attributes }, format: :json
          end

          it "updates question attributes" do
            user_question.reload
            expect(user_question.title).to eq valid_attributes[:title]
            expect(user_question.body).to  eq valid_attributes[:body]
          end

          it "responds with json" do
            expect(response.content_type).to eq "application/json"
          end

          it "responds with :ok status" do
            expect(response).to have_http_status :ok
          end
        end

        context "with nested attachments attributes" do
          let(:attachment) { create(:question_attachment, attachable: user_question) }
          let(:attributes) do
            attachments_attributes = [
              attributes_for(
                :attachment,
                id: attachment.id,
                file: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/test2.png"))
              )
            ]
            attributes_for(:question, attachments_attributes: attachments_attributes)
          end

          context "with :html format" do
            before do
              patch :update, params: { id: user_question, question: attributes }
            end

            it "updates attachment attributes" do
              attachment.reload
              expect(attachment.file.filename).to eq "test2.png"
            end
          end

          context "with :json format" do
            before do
              patch :update, params: { id: user_question, question: attributes },
                             format: :json
            end

            it "updates attachment attributes" do
              attachment.reload
              expect(attachment.file.filename).to eq "test2.png"
            end
          end
        end

        context "with invalid attributes using :html format" do
          before do
            patch :update, params: { id: user_question, question: invalid_attributes }
          end

          it "doesn't update question attributes" do
            user_question.reload
            expect(user_question.title).not_to eq valid_attributes[:title]
            expect(user_question.body).not_to  eq valid_attributes[:body]
          end
        end

        context "with invalid attributes using :json format" do
          before do
            patch :update, params: { id: user_question, question: invalid_attributes },
                           format: :json
          end

          it "doesn't update question attributes" do
            user_question.reload
            expect(user_question.title).not_to eq valid_attributes[:title]
            expect(user_question.body).not_to  eq valid_attributes[:body]
          end

          it "responds with json" do
            expect(response.content_type).to eq "application/json"
          end

          it "responds with :unprocessable_entity status" do
            expect(response).to have_http_status :unprocessable_entity
          end
        end
      end

      context "when is not author" do
        before do
          patch :update, params: { id: question, question: valid_attributes }
        end

        it "redirects to fallback location root_url" do
          expect(response).to redirect_to root_url
        end
      end
    end

    context "when non-authenticated" do
      before do
        patch :update, params: { id: question, question: valid_attributes }
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

        context "with :html request format" do
          it "redirects to 'index'" do
            delete :destroy, params: { id: user_question }
            expect(response).to redirect_to questions_path
          end
        end

        context "with :json request format" do
          before do
            delete :destroy, params: { id: user_question }, format: :json
          end

          it "responds with json" do
            expect(response.content_type).to eq "application/json"
          end

          it "responds with :ok status" do
            expect(response).to have_http_status :ok
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
