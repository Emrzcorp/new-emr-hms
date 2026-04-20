class CreateDiagnoses < ActiveRecord::Migration[7.1]
  def change
    create_table :diagnoses do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.references :medical_record, null: false, foreign_key: true
      t.string :primary_diagnosis
      t.string :secondary_diagnosis
      t.string :icd_code
      t.string :severity
      t.string :status
      t.text :symptoms
      t.text :notes
      t.date :follow_up_date

      t.timestamps
    end
  end
end
