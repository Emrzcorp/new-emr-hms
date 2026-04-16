class MedicalRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_medical_record, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.doctor.present?
      @medical_records = MedicalRecord
                          .where(doctor_id: current_user.doctor.id)
                          .includes(:patient, :doctor)
                          .order(visit_date: :desc)

    elsif current_user.patient.present?
      @medical_records = MedicalRecord
                          .where(patient_id: current_user.patient.id)
                          .includes(:patient, :doctor)
                          .order(visit_date: :desc)
    else
      @medical_records = MedicalRecord.none
    end

    @total_records = @medical_records.count

    @this_week_records = @medical_records.where(
      visit_date: Date.current.beginning_of_week..Date.current.end_of_week
    ).count

    @follow_ups_due = @medical_records.where(
      follow_up_date: Date.current..Date.current + 10.days
    ).count

    @active_cases = @medical_records.where(
      follow_up_date: Date.current..
    ).count

    if current_user.doctor.present?
      @patients = current_user.doctor.patients
      @doctors = [current_user.doctor]
    end
  end

  def new
    @medical_record = MedicalRecord.new
    @patients = Patient.all
    @doctors = Doctor.all
  end

  def create
    @medical_record = MedicalRecord.new(medical_record_params)

    @medical_record.doctor = current_user.doctor

    if @medical_record.save
      redirect_to medical_records_path, notice: "Medical record created successfully."
    else
      @patients = current_user.doctor.patients
      @doctors = [current_user.doctor]
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
    if current_user.doctor.present?
      @medical_record = MedicalRecord.where(doctor_id: current_user.doctor.id).find(params[:id])
    elsif current_user.patient.present?
      @medical_record = MedicalRecord.where(patient_id: current_user.patient.id).find(params[:id])
    else
      redirect_to root_path, alert: "Access denied"
    end
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
