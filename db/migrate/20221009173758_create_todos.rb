class CreateTodos < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.integer :project_id
      t.integer :source_id, null: false
      t.string :source_type, null: false
      t.string :title, null: false
      t.text :content
      t.integer :priority, default: 0, null: false
      t.integer :sort_order, default: 0, null: false
      t.datetime :done_at

      t.timestamps
    end
    add_index :todos, %i[source_id source_type]
  end
end
