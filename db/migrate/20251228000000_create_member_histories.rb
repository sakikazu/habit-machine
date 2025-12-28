class CreateMemberHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :member_histories do |t|
      t.references :history, null: false, foreign_key: true
      t.references :member, null: false, polymorphic: true, index: true

      t.timestamps
    end

    add_index :member_histories, [:history_id, :member_type, :member_id], unique: true, name: 'index_member_histories_on_history_and_member'
  end
end
