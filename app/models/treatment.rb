class Treatment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  belongs_to :diagnosis

  validates :treatment_start_date,
            :treatment_type,
            :treatment_name,
            :priority,
            :description,
            :medication,
            :dosage,
            :frequency,
            :duration,
            :patient_instructions,
            :clinical_notes,
            :status,
            :next_review_date,
            presence: true

  TREATMENT_TYPE = [
    "Medication",
    "Physical Therapy",
    "Surgery",
    "Counseling",
    "Lifestyle Changes",
    "Monitoring",
    "Other"
  ]
end
