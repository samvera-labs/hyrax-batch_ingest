# frozen_string_literal: true
Hyrax::BatchIngest::Engine.routes.draw do
  resources :batches, only: [:index, :show, :new, :create]
end
