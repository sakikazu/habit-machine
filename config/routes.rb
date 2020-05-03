Rails.application.routes.draw do

  ### for API
  namespace 'api' do
    namespace 'v1' do
      post 'sign_in' => 'sessions#create'
      get 'diaries/latest' => 'diaries#latest'
      post 'diaries/:id' => 'diaries#append_memo'
      post 'diaries' => 'diaries#create'
      get 'diaries/:id' => 'diaries#show'
    end
  end


  ### for web
  root to: 'general#top'
  get 'day/:date', to: 'general#day', as: :day
  get 'today', to: 'general#day', as: :today
  get 'search', to: 'general#search', as: :search

  resources :habitodos, except: [:new, :show] do
    collection do
      get 'get_data'
    end
  end

  resources :senses do
    collection do
      get 'past'
      get 'current'
    end
  end

	resources :tags

	# mount RailsAdmin::Engine => '/adamin', :as => 'rails_admin'

	# devise_for :admins

	devise_for :users, skip: [:registrations]
	as :user do
		get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
		put 'users' => 'devise/registrations#update', :as => 'user_registration'
	end

  resources :diaries do
    member do
      put :delete_image
      get :cancel
    end
    collection do
      get 'hilight'
      get 'years/:year', action: :years, as: :years
      post 'append_memo'
    end
  end

	resources :habits do
		collection do
			get 'result'
			get 'top'
		end
	end

	resources :records, only: [] do
		collection do
			post 'update_or_create'
			put 'update_or_create'
		end
	end

end
