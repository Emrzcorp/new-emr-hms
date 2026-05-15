class AddWorkflowFieldsToLaboratoryResults < ActiveRecord::Migration[7.1]
  def change
    add_column :laboratory_results, :workflow_status, :string, default: "ordered"
    add_column :laboratory_results, :sample_collected_at, :datetime
    add_column :laboratory_results, :processing_started_at, :datetime
    add_column :laboratory_results, :completed_at, :datetime
    add_column :laboratory_results, :report_sent_at, :datetime
    add_column :laboratory_results, :report_file, :string
  end
end
