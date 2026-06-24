Rails.application.routes.draw do
  post "ai/improve_text", to: "ai#improve_text", as: :ai_improve_text

  devise_for :users

  # Área dos jogadores
  resources :player_campaigns, only: [ :index ]

  # Área dos mestres
  resources :campaigns do
    member do
      post :add_collection
      post :invite_player

      delete :remove_collection
      delete :remove_player
    end
  end

  resources :collections do
    member do
      post :add_card
      delete :remove_card
    end
  end

  resources :cards do
    collection do
      post :generate_image
    end
  end

  # Root para usuários autenticados
  authenticated :user, ->(u) { u.master? } do
    root "dashboard#index", as: :authenticated_master_root
  end

  authenticated :user, ->(u) { u.player? } do
    root "player_campaigns#index", as: :authenticated_player_root
  end

  # Root para visitantes
  unauthenticated do
    root to: redirect("/users/sign_in"), as: :unauthenticated_root
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
