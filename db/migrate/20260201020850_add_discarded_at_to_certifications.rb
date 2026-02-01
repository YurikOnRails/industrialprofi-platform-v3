class AddDiscardedAtToCertifications < ActiveRecord::Migration[8.0]
  def change
    add_column :certifications, :discarded_at, :datetime
    add_index :certifications, :discarded_at
  end
end
