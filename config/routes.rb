Rails.application.routes.draw do
  resources :questions do
    resources :answers, shallow: true, except: [:show]
  end

  root "questions#index"
end
