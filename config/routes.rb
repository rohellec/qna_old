Rails.application.routes.draw do
  devise_for :users

  concern :commentable do
    resources :comments, shallow: true, only: [:create, :update, :destroy]
  end

  concern :votable do
    member do
      post   "up_vote"
      post   "down_vote"
      delete "delete_vote"
    end
  end

  resources :questions, concerns: [:commentable, :votable] do
    resources :answers, concerns: [:commentable, :votable],
                        shallow: true, only: [:create, :update, :destroy] do
      member do
        post "accept"
        post "remove_accept"
      end
    end
  end

  root "questions#index"
end
