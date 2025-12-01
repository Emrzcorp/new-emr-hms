class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :patient, null: true, foreign_key: true
      t.string :new_patient_name
      t.date :date, null: false
      t.time :time, null: false
      t.integer :duration, default: 30, null: false
      t.string :appointment_type, null: false
      t.string :priority, default: "Normal"
      t.text :reason_for_visit, null: false
      t.text :additional_notes

      t.timestamps
    end
  end
end
