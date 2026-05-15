class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  before_validation :sync_appointment_type

  validate :patient_belongs_to_doctor

  validates  :date,
             :time,
             :duration,
             :priority,
             :reason_for_visit,
             :additional_notes,
             :status,
             :appointment_type_int,
             presence: true

  enum status: { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }

  enum priority: { normal: "Normal", high: "High", urgent: "Urgent" }

  enum appointment_type_int: {
    consultation: 0,
    follow_up: 1,
    emergency: 2,
    routine_checkup: 3
  }

  scope :today, -> { where(date: Date.current) }
  scope :upcoming, -> { where("date > ?", Date.current) }
  scope :pending, -> { where(status: :pending) }

  private

  def sync_appointment_type
    return if appointment_type_int.blank?

    self.appointment_type = appointment_type_int.humanize
  end

  def patient_belongs_to_doctor
    return unless doctor.present? && patient.present?
  end
end

