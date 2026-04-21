class LaboratoryResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor
  before_action :set_result, only: [:show, :edit, :update, :destroy]

  def index
    @results = LaboratoryResult
                .where(doctor_id: @doctor.id)
                .includes(:patient)
                .order(created_at: :desc)

    @patients = @doctor.patients

    # Stats
    @total_tests = @results.count
    @completed = @results.where(status: "Completed").count
    @pending = @results.where(status: "Pending").count
    @abnormal = @results.where(abnormal: true).count

    # Filters
    if params[:query].present?
      @results = @results.joins(:patient).where(
        "patients.first_name ILIKE :q OR laboratory_results.test_name ILIKE :q",
        q: "%#{params[:query]}%"
      )
    end
  end

  def new
    @result = LaboratoryResult.new
    load_dropdowns
  end

  def create
    @result = LaboratoryResult.new(result_params)
    @result.doctor = @doctor

    if @result.save
      redirect_to laboratory_results_path, notice: "Test result created"
    else
      load_dropdowns
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    load_dropdowns
  end

  def update
    if @result.update(result_params)
      redirect_to laboratory_results_path, notice: "Updated successfully"
    else
      load_dropdowns
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @result.destroy
    redirect_to laboratory_results_path, notice: "Deleted"
  end

  private

  def set_doctor
    @doctor = current_user.doctor
  end

  def set_result
    @result = LaboratoryResult.find(params[:id])
  end

  def load_dropdowns
    @patients = @doctor.patients
  end

  def result_params
    params.require(:laboratory_result).permit(
      :patient_id,
      :test_date,
      :test_type,
      :test_name,
      :facility,
      :status,
      :priority,
      :results,
      :reference_range,
      :clinical_interpretation,
      :additional_notes,
      :abnormal,
      :critical,
      :follow_up_required
    )
  end
end