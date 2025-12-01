class MedicalRecord < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  VISIT_TYPES = [
    "Annual Physical",
    "Follow-up",
    "Consultation",
    "Emergency",
    "Preventive Care",
    "Post-Surgery"
  ]

  validates :visit_date, :visit_type, :diagnosis, presence: true
end
