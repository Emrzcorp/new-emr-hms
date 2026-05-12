class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor
  before_action :set_patient, only: [:show, :edit, :update] 

  def index
    @patient = @doctor.patients.new
    
    @patients = @doctor.patients.includes(:medical_records, :appointments)
                .order(created_at: :desc)
                .paginate(page: params[:page], per_page: 10)

    # 🔍 Search
    if params[:query].present?
      q = "%#{params[:query]}%"

      @patients = @patients.where(
        "first_name ILIKE :q OR last_name ILIKE :q OR email_address ILIKE :q OR phone_number ILIKE :q",
        q: q
      )
    end

    # 📌 Status filter (Active / Inactive)
    if params[:status].present?
      case params[:status]
      when "active"
        @patients = @patients.joins(:appointments)
                             .where("appointments.date >= ?", Date.current)
                             .distinct
      when "inactive"
        @patients = @patients.where.not(
          id: Appointment.where("date >= ?", Date.current).select(:patient_id)
        )
      end
    end

    # 📌 Priority filter (based on latest appointment)
    if params[:priority].present?
      @patients = @patients.joins(:appointments)
                           .where(appointments: { priority: params[:priority] })
                           .distinct
    end

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
    @patient = @doctor.patients.new(patient_params)

    unless @patient.valid?
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "patient_form",
            partial: "patients/form",
            locals: { patient: @patient }
          ), status: :unprocessable_entity
        end
      end

      return
    end

    generated_password = nil

    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: patient_params[:email_address])

      if user.new_record?
        generated_password = SecureRandom.hex(8)

        user.password = generated_password
        user.role = :patient

        Rails.logger.info "Patient password: #{generated_password}"

        user.save!
      end

      @patient.user = user
      @patient.save!
    end

    redirect_to patients_path,
      notice: "Patient created. Temporary password: #{generated_password}"

    rescue => e
    Rails.logger.error(e.message)

    flash.now[:alert] = e.message

    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "patient_form",
          partial: "patients/form",
          locals: { patient: @patient }
        ), status: :unprocessable_entity
      end
    end
  end

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

    @latest_priority = @patient.appointments.order(created_at: :desc)

    @treatments = @patient.treatments.order(treatment_start_date: :desc)
    @lab_results = @patient.laboratory_results.order(created_at: :desc)
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