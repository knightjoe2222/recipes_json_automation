Rails.application.routes.draw do
  resources :recipes do
  	collection do
    	get 'recipe'
  	end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'recipes#index' 
end
