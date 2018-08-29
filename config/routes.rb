Rails.application.routes.draw do
  devise_for :users

  concern :votable do
    member do
      post   "up_vote"
      post   "down_vote"
      delete "delete_vote"
    end
  end

  resources :questions, concerns: :votable do
    resources :answers, shallow: true, only: [:create, :update, :destroy] do
      member do
        post "accept"
        post "remove_accept"
      end
    end
  end

  root "questions#index"
end
