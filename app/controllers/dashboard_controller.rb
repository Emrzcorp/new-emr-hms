# class DashboardController < ApplicationController
#   before_action :authenticate_user!

#   def index
#     if current_user.doctor?
#       @patients = current_user.doctor.patients
#       @patient  = current_user.doctor.patients.build
#     end
#   end
# end

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.doctor?
      @doctor = current_user.doctor
      @patients = @doctor.patients

      @appointments = current_user.doctor.appointments.includes(:patient)

      @pending_count  = @appointments.pending.count
      @upcoming_count = @appointments.upcoming.count
      @today_count    = @appointments.today.count
      
    elsif current_user.patient?
      @patient = current_user.patient
      @appointments = @patient.appointments
    end
  end
end

