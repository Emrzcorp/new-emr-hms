class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.doctor?
      @doctor = current_user.doctor
      @patients = @doctor.patients
      @appointments = @doctor.appointments.includes(:patient)

      @pending_count  = @appointments.pending.count
      @upcoming_count = @appointments.upcoming.count
      @today_count    = @appointments.today.count

      @today_appointments = @doctor.appointments
                                .where(date: Date.current)
                                .includes(:patient)
                                .order(:time)
      @pending_tests = MedicalRecord
                      .where(doctor_id: @doctor.id)
                      .where("follow_up_date >= ?", Date.current)
                      .count

      @recent_activities = []

      # Lab Results
      LaboratoryResult.where(doctor_id: @doctor.id).order(created_at: :desc).limit(5).each do |lab|
        @recent_activities << {
          type: "lab",
          title: "Lab results for #{lab.patient&.full_name}",
          subtitle: lab.test_name,
          time: lab.created_at,
          status: lab.status
        }
      end

      # Treatments
      Treatment.where(doctor_id: @doctor.id).order(created_at: :desc).limit(5).each do |t|
        @recent_activities << {
          type: "treatment",
          title: "Treatment for #{t.patient&.full_name}",
          subtitle: t.treatment_name,
          time: t.created_at,
          status: t.status
        }
      end

      # Sort all activities by latest
      @recent_activities = @recent_activities.sort_by { |a| a[:time] }.reverse.first(5)

    elsif current_user.patient.present?
      @patient = current_user.patient

      @appointments = @patient.appointments.includes(:doctor)

      @upcoming_appointments = @appointments.upcoming
      @past_appointments     = @appointments.completed

      @medical_records = @patient.medical_records.order(visit_date: :desc)
    end
  end
end

