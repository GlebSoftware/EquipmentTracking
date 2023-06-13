class AddRedmineTimestamps < ActiveRecord::Migration
  def self.up
    add_column :equipment_assets, :created_on, :datetime
    add_column :equipment_assets, :updated_on, :datetime
  end

  def self.down
    remove_column :equipment_assets, :created_on
    remove_column :equipment_assets, :updated_on
  end
end



