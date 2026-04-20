class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor
  before_action :set_patient, only: [:show, :edit, :update]  # ✅ add update here

  def index
    @patients = @doctor.patients.includes(:medical_records, :appointments)

    @active_patients_count = @doctor.patients
                                  .joins(:appointments)
                                  .where("appointments.date >= ?", Date.current)
                                  .distinct
                                  .count

    @high_priority_count = Appointment.joins(:patient)
                                      .where(patients: { doctor_id: @doctor.id })
                                      .where(priority: "high")
                                      .distinct
                                      .count(:patient_id)

    @today_appointments_count = @doctor.appointments
                                       .where(date: Date.current)
                                       .count
  end

  def new
    @patient = @doctor.patients.build
  end

  def create
    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: patient_params[:email_address])

      if user.new_record?
        user.password = SecureRandom.hex(8)
        user.role = :patient
        user.save!
        user.send_reset_password_instructions
      end

      @patient = @doctor.patients.new(patient_params)
      @patient.user = user

      if @patient.save
        redirect_to patients_path, notice: "Patient created successfully. Login instructions sent."
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue => e
    Rails.logger.error(e.message)
    @patient ||= @doctor.patients.build(patient_params)
    flash.now[:alert] = "Failed to create patient"
    render :new, status: :unprocessable_entity
  end

  # ✅ ADD THIS
  def update
    if @patient.update(patient_params)
      redirect_to patient_path(@patient), notice: "Patient updated successfully"
    else
      flash.now[:alert] = @patient.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @patient = @doctor.patients.find(params[:id])

    @medical_records = @patient.medical_records.includes(:doctor).order(visit_date: :desc)
    @appointments = @patient.appointments.order(date: :desc)

    @is_active = @patient.appointments.where("date >= ?", Date.current).exists?

    @latest_priority = @patient.appointments.order(created_at: :desc).first&.priority
  end

  private

  def set_doctor
    @doctor = current_user.doctor
  end

  def set_patient
    @patient = @doctor.patients.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(
      :first_name, :last_name, :date_of_birth, :gender,
      :phone_number, :email_address, :address1, :address2,
      :city, :state, :country, :zip_code,
      :emergency_contact_number, :emergency_contact_person_name
    )
  end
end