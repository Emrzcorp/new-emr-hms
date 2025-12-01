class CreateMedicalRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :medical_records do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.date :visit_date
      t.string :visit_type
      t.text :diagnosis
      t.text :symptoms
      t.text :treatment_provided
      t.string :blood_pressure
      t.string :heart_rate
      t.string :temperature
      t.string :weight
      t.text :clinical_notes
      t.date :follow_up_date

      t.timestamps
    end
  end
end
