class LaboratoryResult < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  validates :patient_id,
            :doctor_id,
            :test_date,
            :test_type,
            :test_name,
            :facility,
            :status,
            :priority,
            :results,
            :reference_range,
            :clinical_interpretation,
            :additional_notes,
            :abnormal,
            :critical,
            :follow_up_required,
            presence: true

  TEST_TYPES = [
    "Blood Work", "Urine Analysis", "X-Ray", "MRI",
    "CT Scan", "Ultrasound", "ECG", "Biopsy", "Other"
  ]

  STATUS = ["Pending", "Completed", "In Progress", "Cancelled"]
  PRIORITY = ["Routine", "Urgent", "Stat"]
end
