class Treatment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  belongs_to :diagnosis

  validates :treatment_name, :status, presence: true

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
