Rails.application.routes.draw do

  root 'static_pages#home'
  get 'download_video', to: 'devices#download', as: 'download'
  delete 'delete_video', to: 'devices#delete', as: 'delete'
  resource :devices

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
