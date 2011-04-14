Rails.application.routes.draw do
  crm_path = 'admin/crm'

  scope :path => crm_path, :module => :e9_crm do
    resources :campaign_codes,  :except => :show, :controller => 'campaign_codes'
    resources :campaign_groups, :except => :show, :controller => 'campaign_groups'
    resources :companies,       :except => :show, :controller => 'companies'
    resources :contacts,        :except => :show, :controller => 'contacts' do
      collection { get :templates }
    end
    resources :email_templates, :except => :show, :controller => 'email_templates'
    resources :contact_emails, :except => :show, :controller => 'contact_emails'
    resources :deals, :except => :show, :controller => 'deals'

    resources :campaigns, :only  => :index, :controller => 'campaigns' 
    scope :path => :campaigns do
      resources :sales_campaigns, :path => 'sales', :except => [:show], :controller => 'campaigns', :defaults => { :campaign_type => 'sales' }
      resources :advertising_campaigns, :path => 'advertising', :except => [:show],  :controller => 'campaigns', :defaults => { :campaign_type => 'advertising' }
      resources :affiliate_campaigns, :path => 'affiliate', :except => [:show],  :controller => 'campaigns', :defaults => { :campaign_type => 'affiliate' }
      resources :email_campaigns, :path => 'email', :except => [:show], :controller => 'campaigns', :defaults => { :campaign_type => 'email' }
    end
  end

  get  "/#{crm_path}/merge_contacts/:contact_a_id/and/:contact_b_id", :as => :new_contact_merge, :to => 'e9_crm/contact_merges#new'
  post "/#{crm_path}/merge_contacts", :as => :contact_merges, :to => 'e9_crm/contact_merges#create'

  # redirect shows to edits
  get "/#{crm_path}/campaign_groups/:id", :to => redirect("/#{crm_path}/campaign_groups/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/campaigns/advertising/:id", :to => redirect("/#{crm_path}/campaigns/advertising/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/campaigns/affiliate/:id", :to => redirect("/#{crm_path}/campaigns/affiliate/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/campaigns/email/:id", :to => redirect("/#{crm_path}/campaigns/email/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/campaigns/sales/:id", :to => redirect("/#{crm_path}/campaigns/sales/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/deals/:id", :to => redirect("/#{crm_path}/deals/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/contacts/:id", :to => redirect("/#{crm_path}/contacts/%{id}/edit"), :constraints => { :id => /\d+/ }
  get "/#{crm_path}/companies/:id", :to => redirect("/#{crm_path}/companies/%{id}/edit"), :constraints => { :id => /\d+/ }
end
