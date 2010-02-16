class CreateVictories < ActiveRecord::Migration
  def self.up
    create_table :victories do |t|
      t.string :source_ip, :limit => 256, :null => false
      t.string :team_name, :limit => 256, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :victories
  end
end
