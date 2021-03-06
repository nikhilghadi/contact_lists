Rails.application.routes.draw do
  get 'pages/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  match '*path', via: [:options], to: lambda {|_| [204, {'Content-Type' => 'text/plain'}]}
  get '/search_phone_number', to: 'pages#search_contact' 
  post '/add_new_contact', to: 'pages#add_new_contact'
  # Defines the root path route ("/")
  # root "articles#index"
end
