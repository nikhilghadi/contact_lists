class AddIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :contacts, :contact_name
    add_index :phone_numbers, :contact_id
  end
end
