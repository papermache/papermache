Rails.application.routes.draw do
  # get 'test/index'
  # get 'test/sma_detail_view' 
  # get 'test/qr_detail_view' 
  

  get 'papermache/profile'
  get 'papermache/sign_up'
  get 'papermache/search'
  get 'papermache/log_in'
  # get 'analyse/index.html'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  

  devise_for :students, controllers: {
    omniauth_callbacks: "callbacks", 
    registrations: "registrations" 
  }

  root to: "home#index"

  resources :accounts do
    member do
      put 'like', to: 'accounts#upvote' 
      put 'dislike', to: 'accounts#downvote'

      post 'follow', to: 'accounts#follow'
      post 'unfollow', to: 'accounts#unfollow'

      get 'uploadpaper', to: 'accounts#upload_paper'
      get 'qrcode_detail', to: 'test#qr_detail_view'
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
      get 'papers', to: 'papers#search'
      resources :papers do
        member do
          put 'like', to: 'papers#upvote' 
          put 'dislike', to: 'papers#downvote'
          get 'pdfbrowse', to: 'papers#pdfbrowse'
        end
      end
  end

  get 'papermache/papers/:id/sma_detail(.:format)', to: 'test#sma_detail_view'
  get 'tags/:tag', to: 'papermache/papers#search', as: :tag

  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'
  mount AnnotatorStore::Engine, at: '/annotator_store'

end
