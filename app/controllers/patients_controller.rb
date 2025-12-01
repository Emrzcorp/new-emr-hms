class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor
  before_action :set_patient, only: [:show, :edit]


  def index
    @patients = @doctor.patients
  end

  def new
    @doctor = Doctor.find(params[:doctor_id])
    @patient = @doctor.patients.build
  end

  def create
    @doctor = Doctor.find(params[:doctor_id])
    @patient = @doctor.patients.new(patient_params)
    @patient.user_id = current_user.id

    if @patient.save
      redirect_to doctor_patients_path(@doctor), notice: "Patient created successfully"
    else
      render :new, status: :unprocessable_entity
    end
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
      :phone_number, :email_address, :address1, :address2, :city,
      :state, :country, :zip_code, :emergency_contact_number, :emergency_contact_person_name
    )
  end
end

# class PatientsController < ApplicationController
#   before_action :set_patient, only: %i[show edit update destroy]
#   before_action :authenticate_user!
#   before_action :authorize_doctor!, only: %i[new create]

#   def index
#     if current_user.doctor.present?
#       @patients = current_user.doctor.patients.includes(:doctor)
#     else
#       @patients = Patient.none
#     end
#   end

#   def show; end

#   def new
#     if current_user.doctor?
#       @patient = Patient.new
#     else
#       redirect_to dashboard_index_path, alert: "Only doctors can create patients."
#     end
#   end

#   def create
#     if current_user.doctor.present?
#       ActiveRecord::Base.transaction do
#       # Create user for patient login
#       patient_user = User.create!(
#         email: patient_params[:email_address],
#         password: SecureRandom.hex(8),   # or set manually
#         role: :patient
#       )

#         @patient = current_user.doctor.patients.build(patient_params.merge(user: patient_user))
#         if @patient.save
#           # patient_user.send_reset_password_instructions
#         # redirect_to @patient, notice: "Patient created successfully. Login sent to #{patient_user.email}"
#         redirect_to @patient, notice: "Patient created successfully"
#         else
#           render :new, status: :unprocessable_entity
#         end
#       end
#     else
#       redirect_to dashboard_index_path, alert: "Not authorized."
#     end
#   end

#   def edit; end

#   def update
#     if @patient.update(patient_params)
#       redirect_to @patient, notice: "Patient record updated successfully."
#     else
#       render :edit, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @patient.destroy
#     redirect_to patients_path, notice: "Patient record deleted successfully."
#   end

#   private

#   def set_patient
#     @patient = Patient.find(params[:id])
#   end

#   def patient_params
#     params.require(:patient).permit(
#       :first_name, :last_name, :date_of_birth, :gender,
#       :phone_number, :email_address, :address1, :address2, :city,
#       :state, :country, :zip_code, :emergency_contact_number, :emergency_contact_person_name
#     )
#   end

#   def authorize_doctor!
#     unless current_user&.doctor.present?
#       redirect_to dashboard_index_path, alert: "Only doctors can create patients."
#     end
#   end
# end
