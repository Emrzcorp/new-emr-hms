class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
    @user.build_doctor if @user.role == "doctor" && @user.doctor.blank?
    @user.build_patient if @user.role == "patient" && @user.patient.blank?
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update(user_params)
        format.turbo_stream  { redirect_to profile_path, notice: "Profile updated successfully." }
        format.html { redirect_to profile_path, notice: "Profile updated successfully." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("profile_form", partial: "profiles/form", locals: { user: @user }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_params
    case current_user.role
    when "doctor"
      params.require(:user).permit(
        :email,
        doctor_attributes: [
          :id, :first_name, :last_name, :email_address, :phone_number,
          :medical_specialty, :license_number, :npi_number, :professional_bio, :profile_picture
        ]
      )
    when "patient"
      params.require(:user).permit(
        :email,
        patient_attributes: [:id, :first_name, :last_name, :date_of_birth, :profile_picture]
      )
    else
      params.require(:user).permit(:email)
    end
  end
end
