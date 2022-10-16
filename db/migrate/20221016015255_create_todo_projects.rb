class CreateTodoProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :todo_projects do |t|
      t.string :title, null: false
      t.text :content
      t.integer :source_id, null: false
      t.string :source_type, null: false

      t.timestamps
    end
    add_index :todos, %i[source_id source_type]
  end
end
