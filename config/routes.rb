Rails.application.routes.draw do
  devise_for :users

  resources :questions do
    resources :answers, shallow: true, only: [:create, :update, :destroy] do
      member do
        post "accept"
        post "remove_accept"
      end
    end
  end

  root "questions#index"
end
