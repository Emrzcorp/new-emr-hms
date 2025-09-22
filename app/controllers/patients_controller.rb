class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorize_doctor!, only: %i[new create]

  def index
    @patients = Patient.includes(:doctor).all
  end

  def show; end

  def new
    if current_user.doctor?
      @patient = Patient.new
    else
      redirect_to dashboard_index_path, alert: "Only doctors can create patients."
    end
  end

  def create
    if current_user.doctor?
      @patient = Patient.new(patient_params.merge(doctor_id: params[:doctor_id]))
      if @patient.save
        redirect_to @patient, notice: "Patient created successfully."
      else
        render :new
      end
    else
      redirect_to dashboard_index_path, alert: "Not authorized."
    end
  end

  def edit; end

  def update
    if @patient.update(patient_params)
      redirect_to @patient, notice: "Patient record updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path, notice: "Patient record deleted successfully."
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(
      :first_name, :last_name, :date_of_birth, :gender,
      :phone_number, :email_address, :address1, :address2, :city,
      :state, :country, :zip_code, :emergency_contact_number, :emergency_contact_person_name
    )
  end

  def authorize_doctor!
    unless current_user&.doctor.present?
      redirect_to dashboard_index_path, alert: "Only doctors can create patients."
    end
  end
end
