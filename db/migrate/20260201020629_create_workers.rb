class CreateWorkers < ActiveRecord::Migration[8.0]
  def change
    create_table :workers do |t|
      t.references :team, null: false, foreign_key: true
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :employee_number
      t.string :department
      t.string :position
      t.date :hire_date

      t.timestamps
    end
  end
end
