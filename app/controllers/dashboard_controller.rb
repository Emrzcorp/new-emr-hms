class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.doctor?
      @doctor = current_user.doctor
      @patients = @doctor.patients
      @appointments = @doctor.appointments.includes(:patient)

      @pending_count  = @appointments.pending.count
      @upcoming_count = @appointments.upcoming.count
      @today_count    = @appointments.today.count

      @today_appointments = @doctor.appointments
                                .where(date: Date.current)
                                .includes(:patient)
                                .order(:time)

    elsif current_user.patient?
      @patient = current_user.patient
      @appointments = @patient.appointments.includes(:doctor)

      @upcoming_appointments = @appointments.upcoming
      @past_appointments     = @appointments.completed

      @medical_records = @patient.medical_records.order(visit_date: :desc)
    end
  end
end

