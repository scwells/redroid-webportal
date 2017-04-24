Rails.application.routes.draw do

  root 'static_pages#index'
  get 'download_video', to: 'devices#download', as: 'download'
  get 'video', to: 'static_pages#home', as: 'video'
  get 'videos', to: 'static_pages#home', as: 'videos'

  get 'images/*img', to: 'images#fetch'
  put 'images/*img', to: 'images#upload'
  delete 'delete_video', to: 'devices#delete', as: 'delete'
  resource :devices

  # for any other requests, returns 404
  match "*path", to: "images#error_404", via: :all

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
