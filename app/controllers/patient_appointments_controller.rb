class PatientAppointmentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @appointment = Appointment.new
    @doctors = Doctor.all
  end

  def create
    @appointment = current_user.patient.appointments.build(appointment_params)
    @appointment.status = :pending

    if @appointment.save
      redirect_to dashboard_index_path, notice: "Appointment requested successfully!"
    else
      @doctors = Doctor.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :doctor_id, :date, :time, :appointment_type,
      :reason_for_visit
    )
  end
end