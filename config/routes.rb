Rails.application.routes.draw do
  devise_for :users

  resources :questions do
    resources :answers, shallow: true, only: [:create, :update, :destroy]
  end

  root "questions#index"

  post "answers/:id/accept",        to: "answers#accept", as: :accept_answer
  post "answers/:id/remove_accept", to: "answers#remove_accept", as: :remove_accept_answer
end
