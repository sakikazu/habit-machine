class AddFamilyIdToHistories < ActiveRecord::Migration[5.2]
  def change
    add_reference :histories, :family, foreign_key: true, after: :source_type
  end
end
