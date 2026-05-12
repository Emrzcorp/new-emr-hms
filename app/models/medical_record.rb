class MedicalRecord < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  has_many :diagnoses


  VISIT_TYPES = [
    "Annual Physical",
    "Follow-up",
    "Consultation",
    "Emergency",
    "Preventive Care",
    "Post-Surgery"
  ]

  validates :patient_id,
            :doctor_id,
            :visit_date,
            :visit_type,
            :diagnosis,
            :symptoms,
            :treatment_provided,
            :blood_pressure,
            :heart_rate,
            :temperature,
            :weight,
            :clinical_notes,
            :follow_up_date, 
            presence: true

  validate :patient_belongs_to_doctor

  def patient_belongs_to_doctor
    return unless patient && doctor

    if patient.doctor_id != doctor.id
      errors.add(:patient_id, "must belong to the same doctor")
    end
  end
end
