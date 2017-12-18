Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :orders
  resources :locations

  post 'locations/distance'
  post 'locations/driver'

  get 'gopays/index'


  post 'gopays', to: 'gopays#create'
  get 'gopays/:id', to: 'gopays#show'

  patch  'gopays/:id/add', to: 'gopays#add'
  patch  'gopays/:id/reduce', to: 'gopays#reduce'

end
