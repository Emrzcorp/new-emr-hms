class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_doctor!
  before_action :set_doctor

  def index
    @appointments = @doctor.appointments.includes(:patient)\
                    .order(created_at: :desc)
                    .paginate(page: params[:page], per_page: 10)

    # 🔍 Search (text)
    if params[:query].present?
      @appointments = @appointments.joins(:patient).where(
        "patients.first_name ILIKE :q OR patients.last_name ILIKE :q OR appointments.reason_for_visit ILIKE :q OR appointments.appointment_type ILIKE :q",
        q: "%#{params[:query]}%"
      )
    end

    # 📌 Status filter
    if params[:status].present?
      @appointments = @appointments.where(status: params[:status])
    end

    # 📌 Appointment type filter
    if params[:appointment_type].present?
      @appointments = @appointments.where(appointment_type_int: params[:appointment_type])
    end

    # 📅 Date filter
    if params[:date].present?
      @appointments = @appointments.where(date: params[:date])
    end

    @appointments = @appointments.order(created_at: :desc)

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
      redirect_to dashboard_index_path, notice: "Appointment created successfully!"
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

  def update
    @appointment = @doctor.appointments.find(params[:id])

    if @appointment.update(appointment_params)
      redirect_to appointments_path, notice: "Appointment updated successfully!"
    else
      @patients = @doctor.patients
      flash.now[:alert] = @appointment.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
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
      :priority, :reason_for_visit, :additional_notes, :appointment_type_int
    )
  end
end