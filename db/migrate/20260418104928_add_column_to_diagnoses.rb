class AddColumnToDiagnoses < ActiveRecord::Migration[7.1]
  def change
    add_column :diagnoses, :diagnoses_start_date, :date
  end
end
