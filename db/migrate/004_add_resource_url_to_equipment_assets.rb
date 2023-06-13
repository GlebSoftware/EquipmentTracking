class AddResourceUrlToEquipmentAssets < ActiveRecord::Migration
  def self.up
    change_table :equipment_assets do |t|
      t.string :resource_url
    end
  end

  def self.down
    change_table :equipment_assets do |t|
      t.remove :resource_url
    end
  end
end
