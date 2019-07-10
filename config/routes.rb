require 'resque_web'
# This will make the tabs show up.
require 'resque-scheduler'
require 'resque/scheduler/server'

Rails.application.routes.draw do
  root 'home#index'

  resque_web_constraint = lambda do |request|
    current_account = request.env['warden'].user
    current_account.present? && current_account.respond_to?(:admin?) && current_account.admin?
  end

  constraints resque_web_constraint do
    # mount ResqueWeb::Engine => '/resque'
    mount Resque::Server.new, :at => '/resque'
  end

  # get 'sitemap(.:format)' => 'home#sitemap', as: :sitemap

  get '/auth/:provider/callback' => 'sessions#auth_callback'
  get '/auth/failure' => 'sessions#auth_failure'

  scope '/:locale' do
    devise_for :accounts, skip: [:registrations]
    get '(city/:city)' => 'home#index', as: :index

    get 'contractors' => 'home#contractors_index'

    get 'members/:category' => 'contractors#members', as: :members
    get 'about-us' => 'home#about_us'
    get 'contact-us' => 'home#contact_us'
    get 'locations' => 'home#locations'
    get 'sitemap(.:format)' => 'home#sitemap', as: :sitemap
    get 'legal/:slug' => 'home#legal', as: :legal
    get 'job_categories/:skill_id' => 'jobs#categories', as: :job_categories
    get 'skills' => 'jobs#skills', as: :skills
    get 'budgets' => 'jobs#budgets', as: :budgets
    get 'trade/:slug' => 'landing_pages#show', as: :landing_page
    get 'trade/:slug' => 'landing_pages#show', as: :default_landing_page
    get 'sms' => 'sms#index'

    get 'unsubscribe/:token' => 'home#unsubscribe', as: :unsubscribe

    get '404' => 'home#error', defaults: { code: 404 }, as: 'not_found'
    get '500' => 'home#error', defaults: { code: 500 }, as: 'internal_server_error'

    resource :account, only: [:show] do
      post 'change_password' => 'accounts#change_password'
    end

    resource :blog, only: [:show] do
      get 'tag/:tag' => 'blogs#show', as: :tag
      get 'category/:category' => 'blogs#show', as: :category
      get ':post' => 'blogs#post', as: :post
      get ':post' => 'blogs#post', as: :default_post
    end

    resource :contractors, only: [] do
      get 'verification_request' => 'contractors#verification_request'
      put 'verification_request' => 'contractors#form_verification_request'
      get 'commercial_request' => 'contractors#commercial_request'
      put 'commercial_request' => 'contractors#form_commercial_request'

      get 'how-it-works' => 'contractors#how_it_works'
      get 'faq' => 'contractors#faq'
      get 'account_details' => 'contractors#account_details'
      get 'locations' => 'contractors#locations'
      get 'skills' => 'contractors#skills'
      get 'change_password' => 'contractors#change_password'

      get 'notifications' => 'contractors#notifications'
      put 'account_details' => 'contractors#update_account_details'
      post 'skills' => 'contractors#change_skills'
      post 'update_alerts' => 'contractors#update_alerts'
      get 'ratings' => 'contractors#ratings'
      get 'billing/top_up' => 'contractors#top_up'
      get 'billing/subscription' => 'contractors#subscription'
      get 'billing/unsubscribe' => 'contractors#unsubscribe', as: :unsubscribe
      get 'billing/invoices' => 'contractors#invoices'
      get 'billing/invoices/:id' => 'contractors#show_invoice'
      get 'billing_history' => 'contractors#billing_history'

      post 'profile' => 'contractors#profile_update', as: :update_profile
      delete 'photos/:id' => 'contractors#destroy_photo', as: :destroy_photo

      get 'signup' => 'contractors#new'
      post 'create' => 'contractors#create', as: :create
      get 'signup/success' => 'contractors#signup_success'
      put 'update_contractor' => 'contractors#update_contractor'
      get 'message_confirmation' => 'contractors#message_confirmation'
      post 'send_sms_code' => 'contractors#send_sms_code'

      get ':slug' => 'contractors#profile', as: :profile

      patch ':id'  => 'contractors#accept_agreement', as: :accept_agreement
    end

    resources :countries, only: [:index]

    resource :homeowner, only: [:update]

    resource :homeowners, only: [] do
      get 'how-it-works' => 'homeowners#how_it_works'
      get 'faq' => 'homeowners#faq'
      get 'checklist' => 'homeowners#checklist'
    end

    resource :agents, only: [] do
      get 'signup' => 'agents#new'
      post 'create' => 'agents#create', as: :create
      get 'signup/success' => 'agents#signup_success'
    end

    get '/jobs/:state' => 'jobs#index', constraints: { state: /archived|purchased/ }, as: :jobs_index
    resources :jobs, only: [:new, :create, :index, :show, :edit, :update] do
      post 'bid' => 'jobs#bid'
      post 'cancel' => 'jobs#cancel'
      #      get 'edit' => 'jobs#edit'

      resources :ratings, only: [] do
        collection do
          post 'request' => 'ratings#request_a_rating'
          get ':contractor_id' => 'ratings#new', as: ''
          post ':contractor_id' => 'ratings#create', as: :new
        end
      end
    end

    resource :payments, only: [] do
      get 'client_key' => 'payments#client_key'
      post 'top_up' => 'payments#top_up'
      post 'subscribe' => 'payments#subscribe'
      post 'notify' => 'payments#notify'
    end

    resources :questions, path: 'ask-an-expert' do
      collection do
        get :me
      end
    end

    resources :answers, only: [:index, :create, :new] do
      collection do
        get :me
      end
      member do
        post :agree
        post :disagree
      end
    end

    resource :session, only: [:destroy] do
      put 'change_locale', action: :change_locale
    end

    namespace :api, path: 'api/v1' do
      post 'accounts/password/forgot' => 'accounts#forgot_password'
      post 'contractors/create' => 'contractors#create'
      get 'public/profile/:id' => 'contractors#profile'

      get 'countries' => 'home#countries'
      get 'countries/:id' => 'home#cities'
      get 'contractors' => 'home#contractors'
      get 'property_types' => 'home#property_types'
      get 'timings' => 'home#timings'
      get 'skills' => 'home#skills'
      get 'budgets' => 'home#budgets'
      get 'contact_times' => 'home#contact_times'
      post 'ask_an_expert' => 'home#ask_an_expert'

      resource :phone_verifications, only: [:create] do
        put '(:mobile_number)' => 'phone_verifications#verify', as: :verify_number
      end

      resource :sessions, only: [] do
        post 'create' => 'sessions#create'
        delete 'destroy' => 'sessions#destroy'
      end

      resource :contractor, only: []  do
        get 'credit' => 'contractors#credit'
        get 'skills' => 'contractors#skills'
        put 'skills' => 'contractors#change_skills'
        get 'company_details' => 'contractors#company_details'
        put 'company_details' => 'contractors#change_company_details'
        get 'account_details' => 'contractors#account_details'
        put 'account_details' => 'contractors#change_account_details'
        get 'jobs' => 'contractors#jobs'
        get 'photos/:id' => 'contractors#photo'
        get 'job/:id' => 'contractors#job'
        get 'purchased_leads' => 'contractors#purchased_leads'
        get 'my_ratings' => 'contractors#my_ratings'
        post 'jobs/bid' => 'contractors#bid_job'
        get 'request-ratings/:id' => 'contractors#request_ratings'
        put 'change_password' => 'contractors#change_password'
        get 'profile' => 'contractors#profile'
        get 'billing' => 'contractors#billing'
        get 'sms_status' => 'contractors#sms_status'
        post 'update_sms_alert' => 'contractors#update_sms_alert'
        get 'contractor_ratings/:id' => 'contractors#ratings'
      end
      resource :homeowner, only: [:show, :edit] do
        get 'lead_jobs' => 'homeowners#lead_jobs'
        post 'create' => 'homeowners#create'
        put 'update' => 'homeowners#update'
        put 'change_password' => 'homeowners#change_password'
        get 'jobs' => 'homeowners#jobs'
        get 'bidded_jobs' => 'homeowners#bidded_jobs'
        get 'job/:id' => 'homeowners#job'
        get 'job/edit/:id' => 'homeowners#edit_job'
        get 'bidded_job/:id' => 'homeowners#bidded_job'
        put 'job/update' => 'homeowners#update_job'
        post 'job/create' => 'homeowners#create_job'
        post 'job/change_job' => 'homeowners#change_job'
        post 'login_with_social' => 'homeowners#login_with_social'

        resources :jobs, only: [] do
          resources :photos, only: [:create, :index, :show, :destroy]
        end
      end
      resources :ratings, only: [:create, :show] do
        collection do
          post 'create' => 'ratings#create'
        end
      end

      resources :charts, only: [] do
        collection do
          get :residential_jobs
          get :commercial_jobs
          get :contractor_sign_up
          get :commercial_contractor_sign_up
          get :bids
          get :bids_history
          get :revenue
          get :top_up_history
        end
      end
    end

    # Commercial
    namespace :commercial do
      # get 'home/index'
      root to: 'home#index'
      get '' => 'home#index', as: :index

      get 'about-us' => 'statics#about'
      get 'faq' => 'statics#faq'
      get 'concierge_services' => 'statics#concierge_services'
      get 'legal/:slug' => 'home#legal', as: :legal

      # get 'jobs/index'
      get '/jobs/:state' => 'jobs#index', constraints: { state: /archived|purchased/ }, as: :jobs_index
      resources :jobs do
        post 'cancel' => 'jobs#cancel'
        post 'bid' => 'jobs#bid'
        patch 'bids/:id' => 'jobs#quoter_form', as: :update

        resources :ratings, only: [] do
          collection do
            post 'request' => 'ratings#request_a_rating'
            get ':contractor_id' => 'ratings#new', as: ''
            post ':contractor_id' => 'ratings#create', as: :new
          end
        end

        resources :meetings
      end

      resources :clarifications
      resources :invoices
      resources :subscriptions, only: [:index]
      get 'subscriptions/invoices' => 'subscriptions#invoices', as: :subscriptions_invoices
      get 'subscriptions/invoices/:id' => 'subscriptions#show_invoice'
      get 'subscriptions/unsubscribe' => 'subscriptions#unsubscribe', as: :unsubscribe
      get 'subscriptions/waiting_list' => 'subscriptions#waiting_list', as: :waiting_list

      resource :account, only: [:show] do
        post 'change_password' => 'accounts#change_password'
      end
    end
    get 'commercial/ratings' => 'contractors#ratings'
  end

  mount Ckeditor::Engine => '/admin/ckeditor'

  # rubocop:disable Lint/RescueException
  begin
    ActiveAdmin.routes(self)
  rescue Exception => e
    puts "ActiveAdmin: #{e.class}: #{e}"
  end

  default_url_options Rails.application.config.action_mailer.default_url_options

  match '*path', to: 'application#error404', via: :all
end
