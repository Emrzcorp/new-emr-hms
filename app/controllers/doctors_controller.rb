class DoctorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_doctors, only: %i[show edit update destroy]

  def index
    @doctors = Doctor.all
  end

  def new
    @doctor = Doctor.new
  end

  def create
    @doctor = current_user.build_doctor(doctor_params)  # ✅ ensures link with user
    if @doctor.save
      redirect_to doctors_path, notice: "Doctor record created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @doctor.update(doctor_params)
      redirect_to doctors_path, notice: "Doctor record updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_path, notice: "Doctor record deleted successfully!"
  end

  private

  def set_doctors
    @doctor = Doctor.find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(
      :first_name, :last_name, :email_address, :phone_number,
      :medical_specialty, :license_number, :npi_number, :professional_bio
    )
  end
end

