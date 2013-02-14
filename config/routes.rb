Osb::Application.routes.draw do
  resources :payment_terms


  resources :companies

  match "help" => "help#index"
  match "reports/:report_name" => "reports#reports"
  match "reports/data/:report_name" => "reports#reports_data"
  #match "reports/payment_collected" => "reports#payment_collected"
  match "reports" => "reports#index"


  match "dashboard" => "dashboard#index"
  resources :payments do
    collection do
      get 'enter_payment'
      put 'update_individual_payment'
      get 'filter_payments'
      get 'bulk_actions'
      get 'undo_actions'
    end
  end
  resources :taxes do
    collection do
      get 'filter_taxes'
      get 'bulk_actions'
      get 'undo_actions'
    end
  end

  match "invoices/preview" => "invoices#preview"

  match "invoices/unpaid_invoices" => "invoices#unpaid_invoices"

  resources :clients do
    collection do
      get 'filter_clients'
      get 'bulk_actions'
      post 'get_last_invoice'
      get 'undo_actions'
    end
  end


  resources :client_contacts


  devise_for :users, :path_names => { :sign_out => 'logout'}

  devise_scope :user do
    root :to => "devise/sessions#new"
  end

  resources :categories


  resources :items do
    collection do
      get 'filter_items'
      get 'bulk_actions'
      post 'load_item_data'
      get 'duplicate_item'
      get 'undo_actions'
    end
  end


  resources :recurring_profile_line_items


  resources :recurring_profiles


  resources :invoice_line_items


  resources :invoices do
    resources :invoice_line_items
    collection do
      get 'filter_invoices'
      get 'bulk_actions'
      get 'undo_actions'
      post 'duplicate_invoice'
      get 'enter_single_payment'
      get 'send_invoice'
    end
  end


  resources :company_profiles


  resources :client_additional_contacts


  resources :client_billing_infos


  resources :clients


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => redirect("/dashboard")

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
