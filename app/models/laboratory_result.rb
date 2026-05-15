class LaboratoryResult < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  belongs_to :invoice, optional: true

  WORKFLOW_STATUSES = {
    ordered: "ordered",
    sample_collected: "sample_collected",
    processing: "processing",
    completed: "completed",
    report_sent: "report_sent"
  }

  validates :test_date,
            :test_type,
            :test_name,
            :facility,
            :status,
            :priority,
            :results,
            :reference_range,
            :clinical_interpretation,
            :additional_notes,
            presence: true

  validates :test_price, numericality: { greater_than_or_equal_to: 0 }

  TEST_TYPES = [
    "Blood Work", "Urine Analysis", "X-Ray", "MRI",
    "CT Scan", "Ultrasound", "ECG", "Biopsy", "Other"
  ]

  STATUS = ["Pending", "Completed", "In Progress", "Cancelled"]
  PRIORITY = ["Routine", "Urgent", "Stat"]

  def ordered?
    workflow_status == "ordered"
  end

  def sample_collected?
    workflow_status == "sample_collected"
  end

  def processing?
    workflow_status == "processing"
  end

  def completed?
    workflow_status == "completed"
  end

  def report_sent?
    workflow_status == "report_sent"
  end
end
