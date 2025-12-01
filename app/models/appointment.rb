class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  validate :patient_belongs_to_doctor

  validates :date, :time, :duration, :appointment_type, :reason_for_visit, presence: true
  validates :priority, inclusion: { in: %w[Normal High Urgent] }

  enum status: { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }

  scope :today, -> { where(date: Date.current) }
  scope :upcoming, -> { where("date > ?", Date.current) }
  scope :pending, -> { where(status: :pending) }

  private

  def patient_belongs_to_doctor
    if patient && doctor && patient.doctor_id != doctor.id
      errors.add(:patient_id, "must belong to the same doctor as the appointment")
    end
  end
end

