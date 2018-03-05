Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'articles#top'
  resources :articles, only: [:index, :destroy]
  get 'tags/:tag', to: 'articles#index', as: :tag
end
