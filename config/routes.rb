Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	root :to => 'habits#top'

	resources :senses do
		collection do
			get 'past'
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
		end
		collection do
			get 'hilight'
		end
	end

	resources :habits do
		collection do
			get 'result'
			get 'top'
		end
	end

	resources :records do
		collection do
			post 'update_or_create'
			put 'update_or_create'
		end
	end

end
