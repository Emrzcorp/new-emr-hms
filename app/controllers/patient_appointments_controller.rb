class PatientAppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctors, only: [:index, :new, :create]

  def index
    @appointments = current_user.patient.appointments
                        .includes(:doctor)

    if params[:query].present?
      q = "%#{params[:query].strip}%"

      @appointments = @appointments.joins(:doctor).where(
        "doctors.first_name ILIKE :q OR doctors.last_name ILIKE :q OR appointments.reason_for_visit ILIKE :q",
        q: q
      )
    end

    if params[:status].present?
      @appointments = @appointments.where(status: params[:status])
    end

    if params[:appointment_type].present?
      @appointments = @appointments.where(appointment_type_int: params[:appointment_type])
    end

    if params[:date].present?
      @appointments = @appointments.where(date: params[:date])
    end

    @appointments = @appointments
                      .order(created_at: :desc)
                      .paginate(page: params[:page], per_page: 10)

    @appointment = Appointment.new
  end

  def new
    @appointment = Appointment.new
  end

  def create
    @appointment = current_user.patient.appointments.build(appointment_params)
    @appointment.status = :pending

    if @appointment.save
      redirect_to patient_appointments_path, notice: "Appointment requested successfully!"
    else
      @appointments = current_user.patient.appointments.includes(:doctor)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_doctors
    @doctors = Doctor.all
  end

  def appointment_params
    params.require(:appointment).permit(
      :doctor_id, :date, :time, :appointment_type,
      :reason_for_visit, :additional_notes
    )
  end
end