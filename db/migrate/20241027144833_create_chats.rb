class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.string :name
      t.string :llm_model

      t.timestamps
    end
  end
end
