class CreateTreatments < ActiveRecord::Migration[7.1]
  def change
    create_table :treatments do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.references :diagnosis, null: false, foreign_key: true
      t.date :treatment_start_date
      t.string :treatment_type
      t.string :treatment_name
      t.string :priority
      t.text :description
      t.string :medication
      t.string :dosage
      t.string :frequency
      t.string :duration
      t.text :patient_instructions
      t.text :clinical_notes
      t.string :status
      t.date :next_review_date

      t.timestamps
    end
  end
end
