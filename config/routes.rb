Rails.application.routes.draw do
  devise_for :users

  concern :commentable do |options|
    resources :comments, shallow: true, only:     [:create, :update, :destroy],
                                        defaults: { commentable: options[:type] }
  end

  concern :votable do
    member do
      post   "up_vote"
      post   "down_vote"
      delete "delete_vote"
    end
  end

  resources :questions, concerns: :votable do
    concerns :commentable, type: "questions"

    resources :answers, concerns: :votable,
                        shallow: true, only: [:create, :update, :destroy] do
      concerns :commentable, type: "answers"
      member do
        post "accept"
        post "remove_accept"
      end
    end
  end

  root "questions#index"

  mount ActionCable.server => "/cable"
end
