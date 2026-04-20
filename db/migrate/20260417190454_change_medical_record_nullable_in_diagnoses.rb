class ChangeMedicalRecordNullableInDiagnoses < ActiveRecord::Migration[7.1]
  def change
    change_column_null :diagnoses, :medical_record_id, true
  end
end
