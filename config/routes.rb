Rapidfire::Engine.routes.draw do
  resources :surveys do
    get 'results', on: :member
    resources :questions
    resources :attempts, only: [:new, :create, :edit, :update]
    member do
    	get  :clone_modal
    	put  :clone
	end
  end

  root :to => "surveys#index"
end
