Rails.application.routes.draw do
  resources :customers, :only => [:index, :create, :update] do
      collection do
          put 'order'
      end
  end
end
