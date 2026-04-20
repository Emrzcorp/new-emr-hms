class Diagnosis < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  belongs_to :medical_record, optional: true

  has_many :treatments

  validates :primary_diagnosis, presence: true
  validates :severity, inclusion: { in: %w[Mild Moderate Severe Critical] }, allow_blank: true
  validates :status, inclusion: { in: %w[Active Resolved Chronic Under Inverstigation] }, allow_blank: true
end
