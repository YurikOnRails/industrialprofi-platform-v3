class CreateCertifications < ActiveRecord::Migration[8.0]
  def change
    create_table :certifications do |t|
      t.references :worker, null: false, foreign_key: true
      t.references :permit_type, null: false, foreign_key: true
      t.date :issued_at
      t.date :expires_at
      t.string :document_number
      t.string :protocol_number
      t.date :protocol_date
      t.string :training_center
      t.date :next_check_date

      t.timestamps
    end
  end
end
