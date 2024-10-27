class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.integer :role
      t.integer :position
      t.belongs_to :chat
      t.text :content

      t.timestamps
    end
  end
end
