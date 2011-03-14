Rails.application.routes.draw do
  scope :path => :admin, :module => :e9_crm do
    resources :campaign_groups, :except => :show, :controller => 'campaign_groups'
    resources :deals,           :except => :show, :controller => 'deals'
    resources :contacts,        :except => :show, :controller => 'contacts'
    resources :companies,       :except => :show, :controller => 'companies'

    resources :campaigns, :only  => :index, :controller => 'campaigns' 
    scope :path => :campaigns do
      resources :sales_campaigns, :path => 'sales', :except => [:show, :index], :controller => 'campaigns', :defaults => { :campaign_type => 'sales' }
      resources :advertising_campaigns, :path => 'advertising', :except => [:show, :index],  :controller => 'campaigns', :defaults => { :campaign_type => 'advertising' }
      resources :affiliate_campaigns, :path => 'affiliate', :except => [:show, :index],  :controller => 'campaigns', :defaults => { :campaign_type => 'affiliate' }
      resources :email_campaigns, :path => 'email', :except => [:show, :index], :controller => 'campaigns', :defaults => { :campaign_type => 'email' }
    end
  end

  # redirect shows to edits
  get '/admin/campaign_groups/:id', :to => redirect('/admin/campaign_groups/%{id}/edit')
  get '/admin/campaigns/advertising/:id', :to => redirect('/admin/campaigns/advertising/%{id}/edit')
  get '/admin/campaigns/affiliate/:id', :to => redirect('/admin/campaigns/affiliate/%{id}/edit')
  get '/admin/campaigns/email/:id', :to => redirect('/admin/campaigns/email/%{id}/edit')
  get '/admin/campaigns/sales/:id', :to => redirect('/admin/campaigns/sales/%{id}/edit')
  get '/admin/deals/:id', :to => redirect('/admin/deals/%{id}/edit')
  get '/admin/contacts/:id', :to => redirect('/admin/contacts/%{id}/edit')
  get '/admin/companies/:id', :to => redirect('/admin/companies/%{id}/edit')

  # redirect specific campaign type indexes to campaigns with type
  get '/admin/campaigns/advertising', :to => redirect('/admin/campaigns?type=advertising')
  get '/admin/campaigns/affiliate', :to => redirect('/admin/campaigns?type=affiliate')
  get '/admin/campaigns/email', :to => redirect('/admin/campaigns?type=email')
  get '/admin/campaigns/sales', :to => redirect('/admin/campaigns?type=sales')
end
