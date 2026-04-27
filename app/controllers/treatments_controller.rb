class TreatmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor
  before_action :set_treatment, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.doctor.present?
      @doctor = current_user.doctor

      @treatments = Treatment
                      .where(doctor_id: @doctor.id)
                      .includes(:patient, :diagnosis)
                      .order(created_at: :desc)
                      .paginate(page: params[:page], per_page: 10)

      @patients = @doctor.patients
      @diagnoses = Diagnosis.where(doctor_id: @doctor.id)

    elsif current_user.patient.present?
      @patient = current_user.patient

      @treatments = Treatment
                      .where(patient_id: @patient.id)
                      .includes(:doctor, :diagnosis)
                      .order(created_at: :desc)
                      .paginate(page: params[:page], per_page: 10)

      @patients = []
      @diagnoses = @patient.diagnoses
    else
      @treatments = Treatment.none
    end

    if params[:query].present?
      query = params[:query].strip

      @treatments = @treatments.joins(:patient).where(
        "patients.first_name ILIKE :q OR patients.last_name ILIKE :q OR treatments.treatment_name ILIKE :q OR treatments.description ILIKE :q",
        q: "%#{query}%"
      )
    end

    if params[:status].present? && params[:status] != "All Statuses"
      @treatments = @treatments.where(status: params[:status])
    end

    if params[:treatment_type].present? && params[:treatment_type] != "All Types"
      @treatments = @treatments.where(treatment_type: params[:treatment_type])
    end

    @total_treatments     = @treatments.count
    @active_treatments    = @treatments.where(status: "Active").count
    @completed_treatments = @treatments.where(status: "Completed").count
    @medications_count    = @treatments.where.not(medication: nil).count
  end

  def new
    @treatment = Treatment.new
    load_dropdowns
  end

  def create
    @treatment = Treatment.new(treatment_params)
    @treatment.doctor = current_user.doctor

    if @treatment.save
      redirect_to treatments_path, notice: "Treatment created successfully"
    else
      load_dropdowns
      render :index, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    load_dropdowns
  end

  def update
    if @treatment.update(treatment_params)
      redirect_to treatments_path, notice: "Treatment updated successfully"
    else
      load_dropdowns
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @treatment.destroy
    redirect_to treatments_path, notice: "Treatment deleted"
  end

  private

  def set_doctor
    @doctor = current_user.doctor
  end

  def set_treatment
    @treatment = Treatment.find(params[:id])
  end

  def load_dropdowns
    if current_user.doctor.present?
      doctor = current_user.doctor

      @patients = doctor.patients
      @diagnoses = Diagnosis.where(doctor_id: doctor.id)

    else
      @patients = []
      @diagnoses = []
    end
  end

  def treatment_params
    params.require(:treatment).permit(
      :patient_id,
      :diagnosis_id,
      :treatment_start_date,
      :treatment_type,
      :treatment_name,
      :priority,
      :description,
      :medication,
      :dosage,
      :frequency,
      :duration,
      :patient_instructions,
      :clinical_notes,
      :status,
      :next_review_date
    )
  end
end