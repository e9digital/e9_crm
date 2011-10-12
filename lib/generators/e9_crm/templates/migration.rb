class CreateE9CrmStructure < ActiveRecord::Migration
  def self.up
    create_table :page_views, :force => true do |t| 
      t.references :tracking_cookie, :campaign
      t.string :request_path, :user_agent, :referer, :limit => 200
      t.string :session, :limit => 32
      t.string :remote_ip, :limit => 16
      t.boolean :new_visit, :default => false
      t.timestamp :created_at
    end
    add_index 'page_views', 'tracking_cookie_id'
    add_index 'page_views', 'campaign_id'

    create_table :tracking_cookies, :force => true do |t|
      t.references :user
      t.string :hid, :code, :limit => 32
      t.timestamps
    end
    add_index 'tracking_cookies', 'hid'
    add_index 'tracking_cookies', 'code'
    add_index 'tracking_cookies', 'user_id'

    create_table :contacts, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :avatar
      t.string :status
      t.boolean :ok_to_email, :default => true
      t.text :info
      t.references :company
      t.timestamps
    end
    add_index 'contacts', 'company_id'

    create_table :record_attributes, :force => true do |t|
      t.string :type
      t.references :record, :polymorphic => true
      t.text :value, :options, :limit => 3.kilobytes
    end

    create_table :dated_costs, :force => true do |t|
      t.references :costable, :polymorphic => true
      t.integer :cost, :default => 0
      t.date :date
      t.timestamps
    end

    create_table :campaign_groups, :force => true do |t|
      t.string :name
      t.timestamps
    end

    create_table :campaigns, :force => true do |t|
      t.string :type
      t.string :name
      t.references :campaign_group, :affiliate, :sales_person
      t.string :code, :limit => 32
      t.integer :affiliate_fee, :sales_fee, :default => 0
      t.boolean :active, :default => true
      t.timestamps
    end
    add_index 'campaigns', 'campaign_group_id'
    add_index 'campaigns', 'code'

    create_table :companies, :force => true do |t|
      t.string :name
      t.text :info
      t.timestamps
    end

    create_table :contacts_deals, :force => true, :id => false do |t|
      t.references :contact, :deal
    end

    create_table :deals, :force => true do |t|
      t.string :type
      t.string :name
      t.string :lead_name, :lead_email
      t.string :category, :offer_name, :campaign_code
      t.text :info
      t.references :offer, :campaign, :contact, :user
      t.timestamp :created_at, :updated_at, :converted_at, :closed_at
      t.string :status, :limit => 32
      t.integer :value, :default => 0
    end
    add_index 'deals', 'offer_id'
    add_index 'deals', 'campaign_id'
    add_index 'deals', 'tracking_cookie_id'
    add_index 'deals', 'status'

    add_column :users, :contact_id, :integer rescue nil
    add_column :users, :options, :text, :limit => 1.kilobyte rescue nil
  end

  def self.down
    remove_column :users, :contact_id rescue nil
    remove_column :users, :options rescue nil

    drop_table :deals rescue nil
    drop_table :companies rescue nil
    drop_table :campaigns rescue nil
    drop_table :campaign_groups rescue nil
    drop_table :dated_costs rescue nil
    drop_table :record_attributes rescue nil
    drop_table :contacts rescue nil
    drop_table :tracking_cookies rescue nil
    drop_table :page_views rescue nil
  end
end
