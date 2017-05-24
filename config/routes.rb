Rails.application.routes.draw do
  namespace :papermache do
  get 'papers/pdf_browse'
  end

  get 'papermache/profile'
  get 'papermache/sign_up'
  get 'papermache/search'
  get 'papermache/log_in'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  

  devise_for :students, controllers: {
    omniauth_callbacks: "callbacks", 
    registrations: "registrations" 
  }

  root to: "papermache#home"

  resources :accounts do
    member do
      put 'like', to: 'accounts#upvote' 
      put 'dislike', to: 'accounts#downvote'

      post 'follow', to: 'accounts#follow'
      post 'unfollow', to: 'accounts#unfollow'
    end 
    get :autocomplete_account_school, :on => :collection
    get :autocomplete_major_name, :on => :collection
  end

  # resources :papers do 
  #   member do
  #     put 'like', to: 'papers#upvote' 
  #     put 'dislike', to: 'papers#downvote' 
  #   end
  # end

  namespace :papermache do
      # some fb controller specific routes
      resources :papers do
        member do
          put 'like', to: 'papermache/papers#upvote' 
          put 'dislike', to: 'papermache/papers#downvote' 
        end
      end
  end

  get 'tags/:tag', to: 'papermache/papers#index', as: :tag

end
