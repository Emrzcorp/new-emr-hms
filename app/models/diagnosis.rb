class Diagnosis < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  belongs_to :medical_record, optional: true

  has_many :treatments

  validates :primary_diagnosis,
            :secondary_diagnosis,
            :icd_code,
            :symptoms,
            :notes,
            :follow_up_date,
            :diagnoses_start_date, 
            presence: true

  validates :severity, inclusion: { in: %w[Mild Moderate Severe Critical] }, allow_blank: true
  validates :status, inclusion: { in: ["Active", "Resolved", "Chronic", "Under Investigation"] }, allow_blank: true
end
