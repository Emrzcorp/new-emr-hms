class LaboratoryResult < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  validates :test_name, :test_date, :status, presence: true

  TEST_TYPES = [
    "Blood Work", "Urine Analysis", "X-Ray", "MRI",
    "CT Scan", "Ultrasound", "ECG", "Biopsy", "Other"
  ]

  STATUS = ["Pending", "Completed", "In Progress", "Cancelled"]
  PRIORITY = ["Routine", "Urgent", "Stat"]
end
