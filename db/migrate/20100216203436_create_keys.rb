class CreateKeys < ActiveRecord::Migration
  def self.up
    create_table :keys do |t|
      t.string :uid, :limit => 64, :null => false
      t.text :material, :null => false
      t.string :source_ip, :limit => 256, :null => false
      t.integer :calls_left, :null => false

      t.timestamps
    end
    add_index :keys, :uid, :null => false, :unique => true
  end

  def self.down
    drop_table :keys
  end
end
