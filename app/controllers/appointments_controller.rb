class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctor
  # before_action :set_patient
  # before_action :set_appointment, only: %i[show edit update destroy]

  def index
    @appointments = current_user.doctor.appointments.includes(:patient)

    @pending_count  = @appointments.pending.count
	  @upcoming_count = @appointments.upcoming.count
	  @today_count    = @appointments.today.count

    @appointment = Appointment.new
    @patients = current_user.doctor.patients
  end

  def new
    @appointment = Appointment.new
    @patients = current_user.doctor.patients
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.doctor = current_user.doctor
    @appointment.status ||= :pending

    if @appointment.save
      redirect_to appointments_path, notice: "Appointment created successfully!"
    else
    	Rails.logger.error(@appointment.errors.full_messages)
    	flash.now[:alert] = @appointment.errors.full_messages.to_sentence
    	@patients = current_user.doctor.patients
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  	@appointment = Appointment.find(params[:id])
  	@patients = current_user.doctor.patients
  end

  def show
  	@appointment = Appointment.find(params[:id])
  end

  def destroy
  	@appointment = Appointment.find(params[:id])

  	@appointment.destroy
  	redirect_to appointments_path, notice: "Appointment deleted successfully!"
  end

  private

  def set_doctor
    @doctor = current_user.doctor
  end

  # def set_patient
  #   @patient = @doctor.patients.find(params[:patient_id])
  # end

  def set_appointment
    @appointment = @patient.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(
      :patient_id, :new_patient_name, :date, :time, :duration, :appointment_type,
      :priority, :reason_for_visit, :additional_notes
    )
  end
end


# class AppointmentsController < ApplicationController
#   before_action :authenticate_user!
#   before_action :ensure_doctor!

#   def index
#     @appointments = current_user.doctor.appointments.includes(:patient)
#   end

#   def new
#     @appointment = Appointment.new
#     @patients = current_user.doctor.patients
#   end

#   # def create
#   #   @appointment = Appointment.new(appointment_params)
#   #   @appointment.doctor = current_user.doctor

#   #   if @appointment.patient.doctor_id != current_user.doctor.id
#   #     redirect_to appointments_path, alert: "You can only schedule appointments for your own patients."
#   #     return
#   #   end

#   #   if @appointment.save
#   #     redirect_to appointments_path, notice: "Appointment scheduled successfully."
#   #   else
#   #     @patients = current_user.doctor.patients
#   #     render :new, status: :unprocessable_entity
#   #   end
#   # end

#   def create
#   	@appointment = current_user.doctor.appointments.build(appointment_params)

#   	if @appointment.save
#   		redirect_to appointments_path, notice: "Appointment scheduled successfully."
#   	else
#   		@patients = current_user.doctor.patients
#   		render :new, status: :unprocessable_entity
#   	end
#   end


#   private

#   def appointment_params
#     params.require(:appointment).permit(
#       :patient_id, :date, :time, :duration, :appointment_type,
#       :priority, :reason_for_visit, :additional_notes
#     )
#   end

#   def ensure_doctor!
#     redirect_to root_path, alert: "Only doctors can manage appointments." unless current_user.doctor?
#   end
# end
