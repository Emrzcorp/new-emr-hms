class ApplicationController < ActionController::Base
  before_action :set_sidebar_stats
	before_action :configure_permitted_parameters, if: :devise_controller?

	def after_sign_in_path_for(resource)
    dashboard_index_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end

  def set_sidebar_stats
    return unless current_user&.doctor.present?

    doctor = current_user.doctor

    @total_patients = doctor.patients.count

    @today_visits = doctor.appointments
                          .where(date: Date.current)
                          .count

    # Example: adjust based on your schema
    @pending_tests = MedicalRecord
                      .where(doctor_id: doctor.id)
                      .where("follow_up_date >= ?", Date.current)
                      .count
  end
end
