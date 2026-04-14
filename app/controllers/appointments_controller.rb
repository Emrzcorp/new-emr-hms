class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_doctor!
  before_action :set_doctor

  def index
    @appointments = @doctor.appointments.includes(:patient)

    @pending_count  = @appointments.pending.count
    @upcoming_count = @appointments.upcoming.count
    @today_count    = @appointments.today.count

    @appointment = @doctor.appointments.build
    @patients = Patient.all
  end

  def new
    @appointment = @doctor.appointments.build
    @patients = @doctor.patients
  end

  def create
    @appointment = @doctor.appointments.build(appointment_params)
    @appointment.status ||= :pending

    if @appointment.save
      redirect_to appointments_path, notice: "Appointment created successfully!"
    else
      Rails.logger.error(@appointment.errors.full_messages)
      flash.now[:alert] = @appointment.errors.full_messages.to_sentence
      @patients = @doctor.patients
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @appointment = @doctor.appointments.find(params[:id])
    @patients = @doctor.patients
  end

  def show
    @appointment = @doctor.appointments.find(params[:id])
  end

  def destroy
    @appointment = @doctor.appointments.find(params[:id])
    @appointment.destroy
    redirect_to appointments_path, notice: "Appointment deleted successfully!"
  end

  private

  def ensure_doctor!
    unless current_user.doctor?
      redirect_to dashboard_index_path, alert: "Access denied"
    end
  end

  def set_doctor
    @doctor = current_user.doctor
  end

  def appointment_params
    params.require(:appointment).permit(
      :patient_id, :date, :time, :duration, :appointment_type,
      :priority, :reason_for_visit, :additional_notes
    )
  end
end