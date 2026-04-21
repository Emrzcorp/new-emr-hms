class CreateLaboratoryResults < ActiveRecord::Migration[7.1]
  def change
    create_table :laboratory_results do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.date :test_date
      t.string :test_type
      t.string :test_name
      t.string :facility
      t.string :status
      t.string :priority
      t.text :results
      t.string :reference_range
      t.text :clinical_interpretation
      t.text :additional_notes
      t.boolean :abnormal
      t.boolean :critical
      t.boolean :follow_up_required

      t.timestamps
    end
  end
end
