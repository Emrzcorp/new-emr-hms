class DiagnosesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diagnosis, only: [:edit, :update, :show]
  before_action :set_doctor

  def index
	  if current_user.doctor.present?
	    @doctor = current_user.doctor

	    @diagnoses = Diagnosis
	                  .where(doctor_id: @doctor.id)
	                  .includes(:patient)
	                  .order(created_at: :desc)

	    @patients = @doctor.patients

	  elsif current_user.patient.present?
	    @patient = current_user.patient

	    @diagnoses = Diagnosis
	                  .where(patient_id: @patient.id)
	                  .includes(:doctor)
	                  .order(created_at: :desc)

	    @patients = [] # not needed for patient
	  else
	    @diagnoses = Diagnosis.none
	    @patients = []
	  end

	  # Stats (works for both)
	  @total_diagnoses = @diagnoses.count
	  @active_cases    = @diagnoses.where(status: "Active").count
	  @resolving_cases = @diagnoses.where(status: "Resolved").count
	  @follow_up_required = @diagnoses.where("follow_up_date >= ?", Date.current).count

	  # Filters (safe for both roles)
	  if params[:severity].present? && params[:severity] != "All Severities"
	    @diagnoses = @diagnoses.where(severity: params[:severity])
	  end

	  if params[:status].present? && params[:status] != "All Statuses"
	    @diagnoses = @diagnoses.where(status: params[:status])
	  end

	  if params[:query].present?
	    @diagnoses = @diagnoses.joins(:patient).where(
	      "patients.first_name ILIKE :q OR diagnoses.primary_diagnosis ILIKE :q OR diagnoses.icd_code ILIKE :q",
	      q: "%#{params[:query]}%"
	    )
	  end
	end

  def new
	  @diagnosis = Diagnosis.new
	  @patients = current_user.doctor.patients
	end

  def create
	  @diagnosis = Diagnosis.new(diagnosis_params)
	  @diagnosis.doctor = current_user.doctor

	  if @diagnosis.save
	    redirect_to diagnoses_path, notice: "Diagnosis added successfully"
	  else
	    @patients = current_user.doctor.patients
	    render :index, status: :unprocessable_entity
	  end
	end

  def edit
	  @patients = current_user.doctor.patients
	end

	def update
	  if @diagnosis.update(diagnosis_params)
	    redirect_to diagnoses_path, notice: "Diagnosis updated successfully"
	  else
	    @patients = current_user.doctor.patients
	    render :edit, status: :unprocessable_entity
	  end
	end

	def show
	end

  private

  def set_diagnosis
	  @diagnosis = Diagnosis.find(params[:id])
	end

  def set_doctor
    @doctor = current_user.doctor
  end

  def diagnosis_params
    params.require(:diagnosis).permit(
      :patient_id,
      :primary_diagnosis,
      :secondary_diagnosis,
      :icd_code,
      :severity,
      :status,
      :symptoms,
      :notes,
      :follow_up_date,
      :diagnoses_start_date
    )
  end
end