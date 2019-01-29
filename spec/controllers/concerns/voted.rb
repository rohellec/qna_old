shared_examples "voted" do
  let(:votable_type) { described_class.controller_name.singularize.to_sym }
  let(:votable)      { create(votable_type) }

  describe "POST #up_vote" do
    context "when authenticated" do
      before { sign_in user }

      context "when is author" do
        let(:user_votable) { create(votable_type, user: user) }

        it "doesn't change quantity of votes in db" do
          expect do
            post :up_vote, params: { id: user_votable }, format: :json
          end.not_to change(Vote, :count)
        end

        it "returns :unprocessable_entity status when requesting json" do
          post :up_vote, params: { id: user_votable }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when is not author" do
        context "when voting for votable for the first time" do
          it "returns :success status" do
            post :up_vote, params: { id: votable }, format: :json
            expect(response).to have_http_status(:success)
          end

          it "creates new vote for votable" do
            expect do
              post :up_vote, params: { id: votable }, format: :json
            end.to change(votable.votes, :count).by 1
          end

          it "creates new vote for user" do
            expect do
              post :up_vote, params: { id: votable }, format: :json
            end.to change(user.votes, :count).by 1
          end

          it "increases votable's vote rating" do
            expect do
              post :up_vote, params: { id: votable }, format: :json
            end.to change(votable, :vote_rating).by 1
          end
        end

        context "when voting for votable that was already up-voted" do
          let!(:vote) { create(:up_vote, votable: votable, user: user) }

          it "returns :unprocessable_entity status" do
            post :up_vote, params: { id: votable }, format: :json
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "doesn't change quantity of votes in db" do
            expect do
              post :up_vote, params: { id: votable }, format: :json
            end.not_to change(Vote, :count)
          end

          it "doesn't increase votable's vote rating" do
            expect do
              post :up_vote, params: { id: votable }, format: :json
            end.not_to change(votable, :vote_rating)
          end
        end
      end
    end

    context "when non-authenticated" do
      it "doesn't change quantity of votes in db" do
        expect do
          post :up_vote, params: { id: votable }, format: :json
        end.not_to change(Vote, :count)
      end

      it "returns :unprocessable_entity status when requesting json" do
        post :up_vote, params: { id: votable }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST #down_vote" do
    context "when authenticated" do
      before { sign_in user }

      context "when is author" do
        let(:user_votable) { create(votable_type, user: user) }

        it "doesn't change quantity of votes in db" do
          expect do
            post :down_vote, params: { id: user_votable }, format: :json
          end.not_to change(Vote, :count)
        end

        it "returns :unprocessable_entity status when requesting json" do
          post :down_vote, params: { id: user_votable }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when is not author" do
        context "when voting against the votable for the first time" do
          it "returns :success status" do
            post :down_vote, params: { id: votable }, format: :json
            expect(response).to have_http_status(:success)
          end

          it "creates new vote" do
            expect do
              post :down_vote, params: { id: votable }, format: :json
            end.to change(votable.votes, :count).by 1
          end

          it "creates new vote for user" do
            expect do
              post :down_vote, params: { id: votable }, format: :json
            end.to change(user.votes, :count).by 1
          end

          it "decreases votable's rating" do
            expect do
              post :down_vote, params: { id: votable }, format: :json
            end.to change(votable, :vote_rating).by(-1)
          end
        end

        context "when voting against votable that was already down voted" do
          let!(:vote) { create(:down_vote, votable: votable, user: user) }

          it "returns :unprocessable_entity status" do
            post :down_vote, params: { id: votable }, format: :json
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "doesn't change quantity of votes in db" do
            expect do
              post :down_vote, params: { id: votable }, format: :json
            end.not_to change(Vote, :count)
          end

          it "doesn't increase votable's rating" do
            expect do
              post :down_vote, params: { id: votable }, format: :json
            end.not_to change(votable, :vote_rating)
          end
        end
      end
    end

    context "when non-authenticated" do
      it "doesn't change quantity of votes in db" do
        expect do
          post :down_vote, params: { id: votable }, format: :json
        end.not_to change(Vote, :count)
      end

      it "returns :unprocessable_entity status when requesting json" do
        post :down_vote, params: { id: votable }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #delete_vote" do
    context "when authenticated" do
      before { sign_in user }

      context "when deleting vote from votable with user's votes" do
        before { create(:up_vote, votable: votable, user: user) }

        it "returns :success status" do
          delete :delete_vote, params: { id: votable }, format: :json
          expect(response).to have_http_status(:success)
        end

        it "deletes vote from votable" do
          expect do
            delete :delete_vote, params: { id: votable }, format: :json
          end.to change(votable.votes, :count).by(-1)
        end

        it "deletes vote from for user" do
          expect do
            delete :delete_vote, params: { id: votable }, format: :json
          end.to change(user.votes, :count).by(-1)
        end

        context "when it was up voted" do
          it "decreases votable's vote rating" do
            expect do
              delete :delete_vote, params: { id: votable }, format: :json
            end.to change(votable, :vote_rating).by(-1)
          end
        end

        context "when it was down voted" do
          before do
            user.delete_vote(votable)
            create(:down_vote, votable: votable, user: user)
          end

          it "increases votable's vote rating" do
            expect do
              delete :delete_vote, params: { id: votable }, format: :json
            end.to change(votable, :vote_rating).by(1)
          end
        end
      end

      context "when trying to delete vote from votable that has no user votes" do
        it "returns :unprocessable_entity status" do
          delete :delete_vote, params: { id: votable }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "doesn't change quantity of votes in db" do
          expect do
            delete :delete_vote, params: { id: votable }, format: :json
          end.not_to change(Vote, :count)
        end

        it "doesn't change votable's vote rating" do
          expect do
            delete :delete_vote, params: { id: votable }, format: :json
          end.not_to change(votable, :vote_rating)
        end
      end
    end

    context "when non-authenticated" do
      let!(:votable) { create(votable_type) }

      it "doesn't change quantity of votes in db" do
        expect do
          delete :delete_vote, params: { id: votable }, format: :json
        end.not_to change(Vote, :count)
      end

      it "redirects to sign in path" do
        delete :delete_vote, params: { id: votable }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
