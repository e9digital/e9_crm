class CreateE9CrmTables < ActiveRecord::Migration
  def self.up
    create_table :page_views, :force => true do |t| 
      t.references :tracking_cookie
      t.string :request_path, :user_agent, :referer, :limit => 200
      t.string :session, :code, :limit => 32
      t.string :remote_ip, :limit => 16
      t.boolean :new_visit, :default => false
      t.timestamp :created_at
    end
    add_index 'page_views', 'tracking_cookie_id'
    add_index 'page_views', 'code'

    create_table :tracking_cookies, :force => true do |t|
      t.references :user
      t.string :hid, :code, :limit => 32
      t.timestamps
    end
    add_index 'tracking_cookies', 'hid'
    add_index 'tracking_cookies', 'code'
    add_index 'tracking_cookies', 'user_id'

    create_table :contacts, :force => true do |t|
      t.string :email
      t.string :type
      t.timestamps
    end
    add_index 'contacts', 'email'

    create_table :advertising_costs, :force => true do |t|
      t.integer :cost, :default => 0
      t.date :date
    end

    create_table :campaign_groups, :force => true do |t|
      t.string :name
      t.timestamps
    end

    create_table :campaigns, :force => true do |t|
      t.string :type
      t.string :name
      t.references :campaign_group, :affiliate, :sales_person, :advertising_cost
      t.string :code, :limit => 32
      t.integer :affiliate_fee, :sales_fee, :default => 0
      t.integer :status, :limit => 1, :default => 1
      t.timestamps
    end
    add_index 'campaigns', 'campaign_group_id'

    create_table :companies, :force => true do |t|
      t.timestamps
    end

    create_table :deals, :force => true do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :deals rescue nil
    drop_table :companies rescue nil
    drop_table :campaigns rescue nil
    drop_table :campaign_groups rescue nil
    drop_table :advertising_costs rescue nil
    drop_table :contacts rescue nil
    drop_table :tracking_cookies rescue nil
    drop_table :page_views rescue nil
  end
end
