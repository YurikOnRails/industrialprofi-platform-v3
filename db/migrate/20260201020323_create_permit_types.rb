class CreatePermitTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :permit_types do |t|
      t.references :team, null: false, foreign_key: true
      t.string :name
      t.integer :validity_months
      t.string :national_standard
      t.integer :penalty_amount
      t.string :penalty_article
      t.integer :training_hours
      t.boolean :requires_protocol, default: false

      t.timestamps
    end
  end
end
