class LaboratoryResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor, if: -> { current_user.doctor.present? }
  before_action :set_result, only: [
                :show, 
                :edit, 
                :update, 
                :destroy,
                :collect_sample,
                :start_processing,
                :complete_report,
                :send_report
              ]

  def index
	  if current_user.doctor.present?
	    @doctor = current_user.doctor

	    @results = LaboratoryResult
	                .where(doctor_id: @doctor.id)
	                .includes(:patient)
	                .order(created_at: :desc)
                  .paginate(page: params[:page], per_page: 10)

	    @patients = @doctor.patients
      @result = LaboratoryResult.new

	  elsif current_user.patient.present?
	    @patient = current_user.patient

	    @results = LaboratoryResult
	                .where(patient_id: @patient.id)
	                .includes(:doctor)
	                .order(created_at: :desc)
                  .paginate(page: params[:page], per_page: 10)

	    @patients = []
	  else
	    @results = LaboratoryResult.none
	  end

    if params[:query].present?
      @results = @results.joins(:patient).where(
        "patients.first_name ILIKE :q OR patients.last_name ILIKE :q OR laboratory_results.test_name ILIKE :q OR laboratory_results.test_type ILIKE :q",
        q: "%#{params[:query]}%"
      )
    end

    if params[:test_type].present? && params[:test_type] != "All Types"
      @results = @results.where(test_type: params[:test_type])
    end

    if params[:status].present? && params[:status] != "All Statuses"
      @results = @results.where(status: params[:status])
    end

    if params[:test_date].present?
      @results = @results.where(test_date: params[:test_date])
    end

	  @total_tests = @results.count
	  @completed   = @results.where(status: "Completed").count
	  @pending     = @results.where(status: "Pending").count
	  @abnormal    = @results.where(abnormal: true).count
	end

  def new
	  unless current_user.doctor?
	    redirect_to laboratory_results_path, alert: "Access denied"
	    return
	  end

	  @result = LaboratoryResult.new
	  load_dropdowns
	end

  def create
    @result = LaboratoryResult.new(result_params)
    @result.doctor = current_user.doctor

    if @result.save
      LabInvoiceService.new(@result).call if @result.test_price.to_f > 0

      redirect_to laboratory_results_path,
        notice: "Test result created and lab invoice generated",
        status: :see_other
    else
      load_dropdowns

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "laboratory_result_form",
            partial: "laboratory_results/form",
            locals: { result: @result }
          ), status: :unprocessable_entity
        end

        format.html do
          render :index, status: :unprocessable_entity
        end
      end
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

  def collect_sample
    @result.update(
      workflow_status: "sample_collected",
      sample_collected_at: Time.current,
      status: "In Progress"
    )

    redirect_to laboratory_result_path(@result), notice: "Sample collected successfully."
  end

  def start_processing
    @result.update(
      workflow_status: "processing",
      processing_started_at: Time.current,
      status: "In Progress"
    )

    redirect_to laboratory_result_path(@result), notice: "Test processing started."
  end

  def complete_report
    @result.update(
      workflow_status: "completed",
      completed_at: Time.current,
      status: "Completed"
    )

    redirect_to laboratory_result_path(@result), notice: "Lab report completed."
  end

  def send_report
    @result.update(
      workflow_status: "report_sent",
      report_sent_at: Time.current
    )

    redirect_to laboratory_result_path(@result), notice: "Report marked as sent."
  end

  private

  def set_doctor
    @doctor = current_user.doctor
  end

  def set_result
    @result = LaboratoryResult.find(params[:id])
  end

  def load_dropdowns
	  if current_user.doctor.present?
	    doctor = current_user.doctor
	    @patients = doctor.patients
	  else
	    @patients = []
	  end
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
      :follow_up_required,
      :test_price
    )
  end
end