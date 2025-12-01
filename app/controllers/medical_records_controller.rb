class MedicalRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_medical_record, only: [:show, :edit, :update, :destroy]

  def index
    @medical_records = MedicalRecord.includes(:patient, :doctor).order(visit_date: :desc)
    @patients = Patient.all
    @doctors = Doctor.all
  end

  def new
    @medical_record = MedicalRecord.new
    @patients = Patient.all
    @doctors = Doctor.all
  end

  def create
    @medical_record = MedicalRecord.new(medical_record_params)
    if @medical_record.save
      redirect_to medical_records_path, notice: "Medical record created successfully."
    else
      @patients = Patient.all
      @doctors = Doctor.all
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @patients = Patient.all
    @doctors = Doctor.all
  end

  def update
    if @medical_record.update(medical_record_params)
      redirect_to @medical_record, notice: "Medical record updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @medical_record.destroy
    redirect_to medical_records_path, notice: "Medical record deleted."
  end

  private

  def set_medical_record
    @medical_record = MedicalRecord.find(params[:id])
  end

  def medical_record_params
    params.require(:medical_record).permit(
      :patient_id, :doctor_id, :visit_date, :visit_type,
      :diagnosis, :symptoms, :treatment_provided,
      :blood_pressure, :heart_rate, :temperature, :weight,
      :clinical_notes, :follow_up_date
    )
  end
end
