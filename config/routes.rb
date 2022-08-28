# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#            api_v1_sign_in POST   /api/v1/sign_in(.:format)                                                                api/v1/sessions#create
#     api_v1_diaries_latest GET    /api/v1/diaries/latest(.:format)                                                         api/v1/diaries#latest
#                    api_v1 POST   /api/v1/diaries/:id(.:format)                                                            api/v1/diaries#append_memo
#            api_v1_diaries POST   /api/v1/diaries(.:format)                                                                api/v1/diaries#create
#                           GET    /api/v1/diaries/:id(.:format)                                                            api/v1/diaries#show
#                      root GET    /                                                                                        general#top
#                       day GET    /day/:date(.:format)                                                                     general#day
#                     today GET    /today(.:format)                                                                         general#day
#                    search GET    /search(.:format)                                                                        general#search
#        get_data_habitodos GET    /habitodos/get_data(.:format)                                                            habitodos#get_data
#                 habitodos GET    /habitodos(.:format)                                                                     habitodos#index
#                           POST   /habitodos(.:format)                                                                     habitodos#create
#             edit_habitodo GET    /habitodos/:id/edit(.:format)                                                            habitodos#edit
#                  habitodo PATCH  /habitodos/:id(.:format)                                                                 habitodos#update
#                           PUT    /habitodos/:id(.:format)                                                                 habitodos#update
#                           DELETE /habitodos/:id(.:format)                                                                 habitodos#destroy
#               past_senses GET    /senses/past(.:format)                                                                   senses#past
#            current_senses GET    /senses/current(.:format)                                                                senses#current
#                    senses GET    /senses(.:format)                                                                        senses#index
#                           POST   /senses(.:format)                                                                        senses#create
#                 new_sense GET    /senses/new(.:format)                                                                    senses#new
#                edit_sense GET    /senses/:id/edit(.:format)                                                               senses#edit
#                     sense GET    /senses/:id(.:format)                                                                    senses#show
#                           PATCH  /senses/:id(.:format)                                                                    senses#update
#                           PUT    /senses/:id(.:format)                                                                    senses#update
#                           DELETE /senses/:id(.:format)                                                                    senses#destroy
#                      tags GET    /tags(.:format)                                                                          tags#index
#                           POST   /tags(.:format)                                                                          tags#create
#                   new_tag GET    /tags/new(.:format)                                                                      tags#new
#                  edit_tag GET    /tags/:id/edit(.:format)                                                                 tags#edit
#                       tag GET    /tags/:id(.:format)                                                                      tags#show
#                           PATCH  /tags/:id(.:format)                                                                      tags#update
#                           PUT    /tags/:id(.:format)                                                                      tags#update
#                           DELETE /tags/:id(.:format)                                                                      tags#destroy
#          new_user_session GET    /users/sign_in(.:format)                                                                 devise/sessions#new
#              user_session POST   /users/sign_in(.:format)                                                                 devise/sessions#create
#      destroy_user_session DELETE /users/sign_out(.:format)                                                                devise/sessions#destroy
#         new_user_password GET    /users/password/new(.:format)                                                            devise/passwords#new
#        edit_user_password GET    /users/password/edit(.:format)                                                           devise/passwords#edit
#             user_password PATCH  /users/password(.:format)                                                                devise/passwords#update
#                           PUT    /users/password(.:format)                                                                devise/passwords#update
#                           POST   /users/password(.:format)                                                                devise/passwords#create
#    edit_user_registration GET    /users/edit(.:format)                                                                    devise/registrations#edit
#         user_registration PUT    /users(.:format)                                                                         devise/registrations#update
#        delete_image_diary PUT    /diaries/:id/delete_image(.:format)                                                      diaries#delete_image
#              cancel_diary GET    /diaries/:id/cancel(.:format)                                                            diaries#cancel
#           hilight_diaries GET    /diaries/hilight(.:format)                                                               diaries#hilight
#             years_diaries GET    /diaries/years/:year(.:format)                                                           diaries#years
#       append_memo_diaries POST   /diaries/append_memo(.:format)                                                           diaries#append_memo
#                   diaries GET    /diaries(.:format)                                                                       diaries#index
#                           POST   /diaries(.:format)                                                                       diaries#create
#                 new_diary GET    /diaries/new(.:format)                                                                   diaries#new
#                edit_diary GET    /diaries/:id/edit(.:format)                                                              diaries#edit
#                     diary GET    /diaries/:id(.:format)                                                                   diaries#show
#                           PATCH  /diaries/:id(.:format)                                                                   diaries#update
#                           PUT    /diaries/:id(.:format)                                                                   diaries#update
#                           DELETE /diaries/:id(.:format)                                                                   diaries#destroy
#             result_habits GET    /habits/result(.:format)                                                                 habits#result
#                top_habits GET    /habits/top(.:format)                                                                    habits#top
#                    habits GET    /habits(.:format)                                                                        habits#index
#                           POST   /habits(.:format)                                                                        habits#create
#                 new_habit GET    /habits/new(.:format)                                                                    habits#new
#                edit_habit GET    /habits/:id/edit(.:format)                                                               habits#edit
#                     habit GET    /habits/:id(.:format)                                                                    habits#show
#                           PATCH  /habits/:id(.:format)                                                                    habits#update
#                           PUT    /habits/:id(.:format)                                                                    habits#update
#                           DELETE /habits/:id(.:format)                                                                    habits#destroy
#  update_or_create_records POST   /records/update_or_create(.:format)                                                      records#update_or_create
#                           PUT    /records/update_or_create(.:format)                                                      records#update_or_create
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

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
  root to: 'general#day'
  get 'day/:date', to: 'general#day', as: :day
  get 'day_data/:date', to: 'general#day_data'
  get 'month', to: 'general#month', as: :this_month
  get 'month/:month', to: 'general#month', as: :month

  scope :search do
    get '' => 'search#top', as: :search
    get ':content_type' => 'search#content'
  end

  resources :habitodos, except: [:new, :show, :edit] do
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
    end
    collection do
      get 'hilight'
      get 'years/:year', action: :years, as: :years
      post 'append_memo'
      get 'pinned'
    end
  end

	resources :habits
	resources :records, only: [:create, :update]

  resources :children, only: [:index] do
    member do
      # TODO: これをchild_histories配下に書くことはできないか？
      get '/histories/:year', to: 'child_histories#year', as: :year_histories
      get '/histories/:year/:month', to: 'child_histories#month', as: :month_histories
      get :graph
    end
    resources :child_histories, shallow: true, only: [:create, :edit, :update, :destroy]
  end
end
