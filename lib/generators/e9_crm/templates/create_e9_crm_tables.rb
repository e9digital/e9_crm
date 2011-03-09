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

    add_index 'page_views', 'session'
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
  end

  def self.down
    drop_table :page_views
    drop_table :tracking_cookies
  end
end
