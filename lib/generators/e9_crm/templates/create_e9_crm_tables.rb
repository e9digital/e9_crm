class CreateE9CrmTables < ActiveRecord::Migration
  def self.up
    create_table :page_views do |t|
      t.references :tracking_cookie
      t.string :request_path, :user_agent, :referer, :limit => 200
      t.string :session, :code, :limit => 32
      t.string :remote_ip, :limit => 16
      t.boolean :new_visit, :default => false
      t.timestamp :created_at
    end
    add_index 'page_views', 'tracking_cookie_id'
    add_index 'page_views', 'code'

    create_table :tracking_cookies do |t|
      t.references :user
      t.string :hid, :code, :limit => 32
      t.timestamps
    end
    add_index 'tracking_cookies', 'hid'
    add_index 'tracking_cookies', 'code'
    add_index 'tracking_cookies', 'user_id'

    create_table :contacts do |t|
      t.string :type
      t.references :user
      t.timestamps
    end
    add_index 'contacts', 'user_id'

    create_table :advertising_costs do |t|
      t.integer :cost, :default => 0
      t.date :date
    end

    create_table :campaign_groups do |t|
      t.string :name
      t.timestamps
    end

    create_table :campaigns do |t|
      t.string :type
      t.string :name
      t.references :campaign_group, :affiliate, :sales_person, :advertising_cost
      t.string :code, :limit => 32
      t.integer :affiliate_fee, :sales_fee, :default => 0
      t.integer :status, :limit => 1, :default => 1
      t.timestamps
    end
    add_index 'campaigns', 'campaign_group_id'

    create_table :companies do |t|
      t.timestamps
    end

    create_table :deals do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :deals
    drop_table :companies
    drop_table :campaigns
    drop_table :campaign_groups
    drop_table :advertising_costs
    drop_table :contacts
    drop_table :tracking_cookies
    drop_table :page_views
  end
end
