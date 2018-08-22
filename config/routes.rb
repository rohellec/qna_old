Rails.application.routes.draw do
  devise_for :users

  resources :questions do
    resources :answers, shallow: true, only: [:create, :update, :destroy] do
      member do
        post "accept"
        post "remove_accept"
      end
    end

    member do
      post   "up_vote",     defaults: { votable: :question }
      post   "down_vote",   defaults: { votable: :question }
      delete "delete_vote", defaults: { votable: :question }
    end
  end

  root "questions#index"
end
