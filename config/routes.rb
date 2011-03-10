Rails.application.routes.draw do
  scope :path => :admin do
    resources :campaign_groups, :except => :show, :controller => 'e9_crm/campaign_groups'
    resources :deals, :except => :show, :controller => 'e9_crm/deals'
    resources :contacts, :except => :show, :controller => 'e9_crm/contacts'
    resources :companies, :except => :show, :controller => 'e9_crm/companies'
    resources :campaigns, :except => :show, :controller => 'e9_crm/campaigns' 
  end

  get '/admin/campaign_groups/:id', :to => redirect('/admin/campaign_groups/%{id}/edit')
  get '/admin/campaigns/:id', :to => redirect('/admin/campaigns/%{id}/edit')
  get '/admin/deals/:id', :to => redirect('/admin/deals/%{id}/edit')
  get '/admin/contacts/:id', :to => redirect('/admin/contacts/%{id}/edit')
  get '/admin/companies/:id', :to => redirect('/admin/companies/%{id}/edit')
end
