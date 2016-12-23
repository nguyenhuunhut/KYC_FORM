Rails.application.routes.draw do

  devise_for :users, :controllers => {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  scope module: 'api' do
    namespace :v1 do
      resources :users
    end
  end
  post 'v1/users/:id/change_password' => 'api/v1/users#change_password'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
