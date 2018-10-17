Hyrax::BatchIngest::Engine.routes.draw do
  resources :batches, only: [:index, :show] do
    resources :items, only: [:show], controller: 'batch_items'
  end
end
